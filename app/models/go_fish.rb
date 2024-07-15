require_relative 'player'
require_relative 'deck'
require_relative 'round_result'
require 'json'

class GoFish
  include ActiveModel::Serializers::JSON
  class InvalidRank < StandardError; end

  INITIAL_HAND_SIZE = 7
  attr_accessor :players, :deck, :current_player, :game_winner, :players_with_highest_number_of_books, :round_results

  def initialize(players: [], deck: Deck.new, current_player: players.first, game_winner: nil,
                 round_results: [])
    @players = *players
    @deck = deck
    @current_player = current_player
    @game_winner = game_winner
    @players_with_highest_number_of_books = nil
    # example: go_fish.round_results.first.result['player'] = [Message(class: 'player_action', text: 'asked for')]
    @round_results = round_results
  end

  def deal!
    deck.shuffle!
    players.each do |player|
      INITIAL_HAND_SIZE.times { player.add_to_hand([deck.pop_card]) }
    end
  end

  def self.dump(object)
    object.as_json
  end

  def self.load(payload)
    return unless payload

    players = Player.load(payload['players'])
    deck = Deck.load(payload['deck'])
    current_player = Player.find_player(players, payload['current_player'])
    game_winner = Player.find_player(players, payload['game_winner'])
    round_results = RoundResult.load(payload['round_results'])
    GoFish.new(players:, deck:, current_player:, game_winner:, round_results:)
  end

  def play_round!(user_id, opponent_id, card_rank)
    user = Player.find_player(players, user_id.to_i)
    opponent = Player.find_player(players, opponent_id.to_i)

    raise InvalidRank, 'You must ask for a rank you have in your hand' unless user.hand_has_ranks?(card_rank)

    if opponent.hand_has_ranks?(card_rank)
      move_cards_from_opponent_to_player(user, opponent, card_rank)
      append_result_took(user, opponent, card_rank)
    else
      card = fish_for_card
      process_card_draw(user, opponent, card_rank, card)
      switch_players if card.rank != card_rank
    end
    finalize_turn
  end

  def append_result_took(player1, player2, card_rank)
    new_result = RoundResult.new
    new_result.add_ask_result(player1, player2, card_rank)
    new_result.add_took_result(player1, player2, card_rank)
    round_results << new_result
  end

  def append_result_drew_matched(player1, player2, card_rank, rank_drawn:, suit_drawn:)
    new_result = RoundResult.new
    new_result.add_ask_result(player1, player2, card_rank)
    new_result.add_drew_matched_result(player1, player2, card_rank, rank_drawn, suit_drawn)
    round_results << new_result
  end

  def append_result_drew_not_matched(player1, player2, card_rank, rank_drawn:, suit_drawn:)
    new_result = RoundResult.new
    new_result.add_ask_result(player1, player2, card_rank)
    new_result.add_drew_not_matched_result(player1, player2, card_rank, rank_drawn, suit_drawn)
    round_results << new_result
  end

  def process_card_draw(player1, player2, card_rank, card)
    if card.rank == card_rank
      append_result_drew_matched(player1, player2, card_rank, rank_drawn: card.rank, suit_drawn: card.suit)
    else
      append_result_drew_not_matched(player1, player2, card_rank, rank_drawn: card.rank, suit_drawn: card.suit)
    end
  end

  def move_cards_from_opponent_to_player(player, opponent, rank)
    cards = opponent.hand.select { |card| card.rank == rank }
    player.add_to_hand(cards)
    opponent.remove_by_rank(rank)
  end

  def fish_for_card
    card = deck.pop_card
    current_player.add_to_hand(card)
    card
  end

  def finalize_turn
    current_player.add_to_books
    check_for_winner
  end

  def check_for_winner
    return unless deck.cards.empty?

    return if players.any? { |player| player.hand.count > 0 }

    max_number_of_books = players.map { |player| player.books.count }.max

    self.players_with_highest_number_of_books = players.select { |player| player.books.count == max_number_of_books }

    compare_book_values(players_with_highest_number_of_books)

    game_winner
  end

  def compare_book_values(players_with_highest_number_of_books)
    self.game_winner = players_with_highest_number_of_books.max_by { |player| player.score }
  end

  def switch_players
    current_player_index = players.index(current_player)
    next_player_index = (current_player_index + 1) % players.size
    self.current_player = players[next_player_index]
  end

  def attributes=(hash)
    hash.each do |key, value|
      send("#{key}=", value)
    end
  end

  def attributes
    instance_values
  end
end

require_relative 'player'
require_relative 'deck'
require_relative 'round_result'
require 'json'

class GoFish
  include ActiveModel::Serializers::JSON
  class InvalidTurn < StandardError; end

  INITIAL_HAND_SIZE = 7
  attr_accessor :players, :deck, :current_player, :game_winner, :players_with_highest_number_of_books, :round_results

  def initialize(players: [], deck: Deck.new, current_player: players.first, game_winner: nil,
                 round_results: [])
    @players = *players
    @deck = deck
    @current_player = current_player
    @game_winner = game_winner
    @players_with_highest_number_of_books = nil
    @round_results = round_results
  end

  def deal!
    deck.shuffle!
    players.each do |player|
      INITIAL_HAND_SIZE.times { player.add_to_hand([deck.pop_card]) }
    end
  end

  def can_take_turn?(user_id)
    return true if current_player.user_id == user_id && current_player.hand.size.positive? && game_winner.nil?

    false
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
    round_results = payload['round_results']&.map { |result| RoundResult.load(result) }
    GoFish.new(players:, deck:, current_player:, game_winner:, round_results:)
  end

  def play_round!(user_id, opponent_id, card_rank)
    user, opponent = set_user_and_opponent(user_id, opponent_id)
    raise InvalidTurn, 'Game is over.' unless game_winner.nil?
    raise InvalidTurn, 'You must ask for a rank you have in your hand.' unless user.hand_has_ranks?(card_rank)

    if opponent.hand_has_ranks?(card_rank)
      move_cards_from_opponent_to_player(user, opponent, card_rank)
    else
      card = handle_go_fish(card_rank)
    end
    finalize_turn(user, opponent, card_rank, card)
  end

  def handle_go_fish(card_rank)
    return if deck.cards.empty?

    card = fish_for_card
    switch_players if card.rank != card_rank
    card
  end

  def set_user_and_opponent(user_id, opponent_id)
    user = Player.find_player(players, user_id.to_i)
    opponent = Player.find_player(players, opponent_id.to_i)
    raise Player::InvalidOpponent, 'You cannot ask yourself for cards.' unless user != opponent

    [user, opponent]
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

  def finalize_turn(round_player, opponent, card_rank, card = nil)
    book_rank = round_player.add_to_books
    check_for_winner
    check_empty_hand_or_draw
    round_results.unshift(if card.nil?
                            round_result = RoundResult.new(id: (round_results.length + 1), player_name: round_player.name, opponent_name: opponent.name, rank: card_rank,
                                                           book_rank:, game_winner: game_winner&.name)
                          else
                            round_result = RoundResult.new(id: (round_results.length + 1), player_name: round_player.name, opponent_name: opponent.name, rank: card_rank,
                                                           rank_drawn: card.rank, suit_drawn: card.suit, book_rank:, game_winner: game_winner&.name)
                          end)
    skip_turn
    round_result.round_result_log
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

  def skip_turn
    return if game_winner

    switch_players until current_player.hand.any?
  end

  def check_empty_hand_or_draw(current_player = self.current_player)
    nil if players.all? { |player| player.hand.count > 0 }

    players.each do |player|
      if player.hand.empty?
        player.add_to_hand([deck.pop_card]) until deck.cards.empty? || player.hand.count == INITIAL_HAND_SIZE
      end
    end
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

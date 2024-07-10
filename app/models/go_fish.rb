require_relative 'player'
require_relative 'deck'
require 'json'

class GoFish
  include ActiveModel::Serializers::JSON
  INITIAL_HAND_SIZE = 7
  attr_accessor :players, :deck, :current_player, :game_winner

  def initialize(players: [], deck: Deck.new, current_player: nil, game_winner: nil)
    @players = *players
    @deck = Deck.new
    @current_player = current_player
    @game_winner = game_winner
  end

  def deal!
    players.each do |player|
      INITIAL_HAND_SIZE.times { player.add_to_hand([deck.pop_card]) }
    end
  end

  def self.dump(object)
    object.as_json
  end

  # TODO: Each class should know how to load its own
  def self.load(payload)
    return unless payload

    players = load_players(payload['players'])
    deck = load_deck(payload['deck'])
    current_player = find_player(players, payload['current_player'])
    game_winner = find_player(players, payload['game_winner'])
    GoFish.new(players:, deck:, current_player:, game_winner:)
  end

  def self.find_player(players, player_data)
    return nil unless player_data

    players.find { |player| player.user_id == player_data['user_id'] }
  end

  def self.load_players(players)
    players.map do |player|
      Player.new(
        user_id: player['user_id'],
        hand: load_cards(player['hand']),
        books: player['books'].map { |book| create_book(book) }
      )
    end
  end

  def self.create_book(book)
    cards = load_cards(book['cards'])
    Book.new(cards)
  end

  def self.load_deck(deck)
    Deck.new.tap do |d|
      d.cards = load_cards(deck['cards'])
    end
  end

  def self.load_cards(cards)
    cards.map { |card| Card.new(card['rank'], card['suit']) }
  end

  def play_round!
    players.each do |player|
      player.add_to_hand([deck.pop_card]) if player.hand.empty?
      player.add_to_books
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

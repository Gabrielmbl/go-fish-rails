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

  def self.load(payload)
    return unless payload

    players = Player.load_players(payload['players'])
    deck = Deck.load_deck(payload['deck'])
    current_player = Player.find_player(players, payload['current_player'])
    game_winner = Player.find_player(players, payload['game_winner'])
    GoFish.new(players:, deck:, current_player:, game_winner:)
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

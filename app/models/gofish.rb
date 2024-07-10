require_relative 'player'
require_relative 'deck'

class GoFish
  attr_accessor :players, :deck

  INITIAL_HAND_SIZE = 7

  def initialize(players)
    @players = *players
    @deck = Deck.new
  end

  def deal!
    players.each do |player|
      INITIAL_HAND_SIZE.times { player.add_to_hand([deck.pop_card]) }
    end
  end
end

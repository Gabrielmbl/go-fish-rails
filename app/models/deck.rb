require_relative 'card'

class Deck
  attr_reader :ranks, :suits, :num_cards
  attr_accessor :cards

  def initialize(cards = create_deck)
    @cards = cards
    @num_cards = cards.count
  end

  def self.load(deck)
    cards = deck['cards'].map { |card_data| Card.load(card_data) }
    Deck.new(cards)
  end

  def create_deck
    cards = Card::SUITS.flat_map do |suit|
      Card::RANKS.map do |rank|
        Card.new(rank, suit)
      end
    end
  end

  def pop_card
    cards.pop
  end

  def current_num_cards
    cards.count
  end

  def shuffle!
    original_cards = cards.dup
    cards.shuffle! until original_cards != cards
  end
end

require_relative 'card'

class Deck
  attr_reader :ranks, :suits, :num_cards
  attr_accessor :cards

  def initialize
    @cards = create_deck
    @num_cards = cards.count
  end

  def self.load_deck(deck)
    Deck.new.tap do |d|
      d.cards = Card.load_cards(deck['cards'])
    end
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

  def shuffle
    original_cards = cards.dup
    cards.shuffle! until original_cards != cards
  end
end

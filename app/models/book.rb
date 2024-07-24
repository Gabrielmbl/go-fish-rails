require_relative 'card'

class Book
  attr_accessor :cards

  def initialize(cards = [])
    @cards = cards
  end

  def self.load(book)
    cards = book['cards'].map { |card_data| Card.load(card_data) }
    Book.new(cards)
  end

  def value
    cards.first.numerical_rank
  end

  delegate :count, to: :cards
end

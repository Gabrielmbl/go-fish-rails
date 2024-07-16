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
    sum = 0
    cards.each do |card|
      sum += card.numerical_rank
    end
    sum
  end

  delegate :count, to: :cards
end

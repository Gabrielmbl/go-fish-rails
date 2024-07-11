require_relative 'card'

class Book
  attr_accessor :cards

  def initialize(cards = [])
    @cards = cards
  end

  def self.load(book)
    cards = Card.load(book['cards'])
    Book.new(cards)
  end

  def value
    sum = 0
    cards_array.each do |cards|
      sum += cards.first.numerical_rank
    end
    sum
  end

  delegate :count, to: :cards_array
end

require 'rails_helper'

RSpec.describe Book, type: :model do
  let(:card1) { Card.new('A', 'Spades') }
  let(:card2) { Card.new('A', 'Hearts') }
  let(:card3) { Card.new('A', 'Diamonds') }
  let(:card4) { Card.new('A', 'Clubs') }
  let(:book) { Book.new([card1, card2, card3, card4]) }

  describe '#load_book' do
    it 'loads a book from a hash' do
      json = book.as_json
      loaded_book = Book.create_book(json)

      expect(loaded_book).to be_a(Book)
      expect(loaded_book.cards.size).to eq(book.cards.size)
      expect(loaded_book.cards).to all(be_a(Card))
      expect(json).to match_json_schema('book')
    end
  end
end

require 'rails_helper'

RSpec.describe Deck, type: :model do
  let(:deck) { Deck.new }
  describe '#load_deck' do
    it 'loads a deck from a hash' do
      json = deck.as_json
      loaded_deck = Deck.load_deck(json)

      expect(loaded_deck).to be_a(Deck)
      expect(loaded_deck.cards.size).to eq(deck.cards.size)
      expect(loaded_deck.cards).to all(be_a(Card))
      expect(json).to match_json_schema('deck')
    end
  end
end

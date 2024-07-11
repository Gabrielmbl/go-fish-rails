require 'rails_helper'

RSpec.describe Deck, type: :model do
  let(:deck) { Deck.new }
  describe '#load' do
    it 'loads a deck from a hash' do
      json = deck.as_json
      loaded_deck = Deck.load(json)

      expect(loaded_deck.cards).to match_array(deck.cards)
      expect(json).to match_json_schema('deck')
    end
  end
end

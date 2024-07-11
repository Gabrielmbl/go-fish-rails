require 'rails_helper'

RSpec.describe Card, type: :model do
  let(:card1) { Card.new('A', 'Spades') }
  let(:card2) { Card.new('2', 'Hearts') }

  describe '#load_card' do
    it 'loads a card from a hash' do
      cards = Card.load([card1.as_json, card2.as_json])

      expect(cards).to match_array([card1, card2])
      expect(cards[0].as_json).to match_json_schema('card')
    end
  end
end

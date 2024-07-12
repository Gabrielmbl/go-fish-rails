require 'rails_helper'

RSpec.describe Card, type: :model do
  let(:card1) { Card.new('A', 'Spades') }

  describe '#load_card' do
    it 'loads a card from a hash' do
      loaded_card1 = Card.load(card1.as_json)
      expect(loaded_card1).to eq card1
    end
  end
end

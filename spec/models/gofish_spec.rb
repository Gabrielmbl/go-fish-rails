require 'rails_helper'

RSpec.describe Game, type: :model do
  let(:player1) { Player.new('gabriel') }
  let(:player2) { Player.new('lucas') }
  let(:player3) { Player.new('someoneelse') }
  let(:game) { GoFish.new([player1, player2]) }

  describe '#deal!' do
    it 'deals cards to each player' do
      game.deal!

      expect(player1.hand.size).to eq GoFish::INITIAL_HAND_SIZE
      expect(player2.hand.size).to eq GoFish::INITIAL_HAND_SIZE
    end
  end

  describe '#play_round!' do
  end
end

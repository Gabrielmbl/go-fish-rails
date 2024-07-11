require 'rails_helper'

RSpec.describe Game, type: :model do
  let!(:game) { create(:game) }
  let!(:user1) { create(:user) }
  let!(:user2) { create(:user) }

  describe '#start!' do
    context 'when there are not enough players' do
      it 'should return false' do
        expect(game.start!).to be_falsey
      end
    end

    context 'when there are enough players' do
      before do
        create(:game_user, game:, user: user1)
        create(:game_user, game:, user: user2)
      end

      it 'should populate the game with players' do
        game.start!
        expect(game.go_fish.players.size).not_to be_zero
      end

      it 'should initialize with correct players' do
        game.start!
        expect(game.go_fish.players.map(&:user_id)).to match_array([user1.id, user2.id])
      end

      it 'should deal cards to each player' do
        game.start!
        expect(game.go_fish.players.all? { |player| player.hand.size == GoFish::INITIAL_HAND_SIZE }).to be
      end
    end
  end

  describe '#go_fish' do
    it 'returns a GoFish object' do
      players = [user1, user2].map { |user| Player.new(user_id: user.id) }
      go_fish = GoFish.new(players:)
      game.update(go_fish:)
      expect(game.go_fish).to be_an_instance_of(GoFish)
    end
  end
end

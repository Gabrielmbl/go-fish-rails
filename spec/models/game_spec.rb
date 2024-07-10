require 'rails_helper'

RSpec.describe Game, type: :model do
  let!(:game) { create(:game) }
  let!(:user1) { create(:user) }
  let!(:user2) { create(:user) }

  before do
    create(:game_user, game:, user: user1)
    create(:game_user, game:, user: user2)
  end

  # TODO: Test behaviors. Doesn't start game if there are not enough players
  # if not, it should add players, and deals cards
  # it has players, and players have more than 0 cards
  describe '#start!' do
    it 'should update the database with the game started_at time' do
      expect(game.go_fish).to be_nil
      game.start!

      expect(game.go_fish).not_to be_nil
    end
  end

  describe '#go_fish' do
    it 'gives JSON form object' do
      players = [user1, user2].map { |user| Player.new(user_id: user.id) }
      go_fish = GoFish.new(players:)
      game.update(go_fish:)
      expect(game.go_fish).not_to be_nil
    end

    xit 'gives object from JSON' do
    end
  end
end

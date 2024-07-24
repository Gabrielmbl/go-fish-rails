require 'rails_helper'
# TODO: Implement testing with a game that is not over yet
RSpec.describe Leaderboard, type: :model do
  let!(:game) { create(:game, name: 'Game1') }
  let(:user) { create(:user) }
  let(:opponent) { create(:user) }

  before do
    game.users << user
    game.users << opponent
    game.start!
    game.reload
    until game.go_fish.game_winner
      current_player = game.go_fish.current_player
      opponents = game.go_fish.players.reject { |player| player.user_id == current_player.user_id }
      opponent_id = opponents.sample.user_id
      rank = current_player.hand.sample.rank
      game.play_round!(current_player.user_id, opponent_id, rank)
    end
  end

  describe 'Leaderboard has correct information' do
    let(:leaderboards) { Leaderboard.all }

    it 'displays the correct total games joined and completed by each user' do
      expect(leaderboards.map(&:total_games_joined)).to eq([1, 1])
      expect(leaderboards.map(&:total_games_completed)).to eq([1, 1])
    end

    it 'displays the correct number of wins and losses' do
      expect(leaderboards.map(&:wins)).to include(1)
      expect(leaderboards.map(&:losses)).to include(1)
    end

    it 'displays the correct win percentage' do
      expect(leaderboards.map(&:win_ratio)).to include(100.0)
      expect(leaderboards.map(&:win_ratio)).to include(0.0)
    end

    it 'displays the total time played' do
      expected_time = game.updated_at - game.created_at
      tolerance = 0.1

      leaderboards.each do |leaderboard|
        actual_time = leaderboard.total_time_played
        expect(actual_time).to be_within(tolerance).of(expected_time)
      end
    end
  end
end

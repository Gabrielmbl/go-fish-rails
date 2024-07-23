class Leaderboard < ApplicationRecord
  self.primary_key = :user_id

  def readonly?
    true
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[user_name total_games_joined total_games_completed total_time_played wins losses win_rate]
  end
end

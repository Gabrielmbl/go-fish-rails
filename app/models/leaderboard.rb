# TODO: Make tests for this model
class Leaderboard < ApplicationRecord
  self.primary_key = :user_id

  def readonly?
    true
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[user_name total_games_joined total_games_completed total_time_played wins losses win_rate]
  end

  def formatted_total_time_played
    Time.at(total_time_played).utc.strftime('%H:%M:%S')
  end
end

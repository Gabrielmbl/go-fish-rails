require_relative 'player'
require_relative 'go_fish'

class Game < ApplicationRecord
  class InvalidTurn < StandardError; end

  validates :name, presence: true
  validates :required_number_players, presence: true, numericality: { only_integer: true, greater_than: 1 }

  scope :ordered, -> { order(id: :desc) }
  scope :joinable, -> { order(created_at: :desc).where(finished_at: nil).where.not(started_at: nil) }
  after_update_commit lambda {
                        users.each do |user|
                          broadcast_refresh_to "games:#{id}:users:#{user.id}"
                        end
                        broadcast_refresh_to 'status' if !started_at.nil? && finished_at.nil?
                        broadcast_refresh_to 'history' unless finished_at.nil?
                      }

  has_many :game_users, dependent: :destroy
  has_many :users, through: :game_users

  serialize :go_fish, GoFish

  def self.ransackable_associations(auth_object = nil)
    %w[game_users users]
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[created_at finished_at go_fish id id_value name required_number_players started_at
updated_at]
  end

  def start!
    return false unless enough_players?

    players = users.map { |user| Player.new(user_id: user.id) }
    go_fish = GoFish.new(players:)
    go_fish.deal!
    update(go_fish:, started_at: Time.zone.now)
  end

  def play_round!(user_id, opponent_id, card_rank)
    go_fish.play_round!(user_id, opponent_id, card_rank)

    if go_fish.game_winner
      if go_fish.game_winner.is_a?(Array)
        go_fish.game_winner.each do |winner|
          determine_winner!(winner.user_id)
        end
      else
        determine_winner!(go_fish.game_winner.user_id)
      end
      update(finished_at: Time.zone.now)
    end

    save!
  end

  def enough_players?
    users.count == required_number_players
  end

  def determine_winner!(user_id)
    game_users.find_by(user_id:).update(winner: true)
  end

  def duration
    total_milliseconds = duration_in_milliseconds

    hours = (total_milliseconds / 3_600_000).to_i
    minutes = (total_milliseconds % 3_600_000 / 60_000).to_i
    seconds = (total_milliseconds % 60_000 / 1000).to_i
    milliseconds = (total_milliseconds % 1000).to_i

    format('%02dh:%02dm:%02ds:%03dms', hours, minutes, seconds, milliseconds)
  end

  def duration_in_milliseconds
    return 0 if updated_at.nil? || started_at.nil?

    end_time = finished_at || updated_at
    ((end_time - started_at) * 1000).to_i
  end

  def number_of_rounds_played
    go_fish.round_results.size
  end
end

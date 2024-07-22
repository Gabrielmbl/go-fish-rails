require_relative 'player'
require_relative 'go_fish'

class Game < ApplicationRecord
  class InvalidTurn < StandardError; end

  validates :name, presence: true
  validates :required_number_players, presence: true, numericality: { only_integer: true, greater_than: 1 }

  scope :ordered, -> { order(id: :desc) }
  after_update_commit lambda {
                        users.each do |user|
                          broadcast_refresh_to "games:#{id}:users:#{user.id}"
                        end
                      }

  has_many :game_users, dependent: :destroy
  has_many :users, through: :game_users

  serialize :go_fish, GoFish

  def start!
    return false unless enough_players?

    players = users.map { |user| Player.new(user_id: user.id) }
    go_fish = GoFish.new(players:)
    go_fish.deal!
    update(go_fish:, started_at: Time.zone.now)
  end

  def play_round!(user_id, opponent_id, card_rank)
    go_fish.play_round!(user_id, opponent_id, card_rank)
    determine_winner!(go_fish.game_winner.user_id) if go_fish.game_winner
    save!
  end

  def enough_players?
    users.count == required_number_players
  end

  def determine_winner!(user_id)
    game_users.find_by(user_id:).update(winner: true)
  end
end

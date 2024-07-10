require_relative 'player'
require_relative 'gofish'

class Game < ApplicationRecord
  validates :name, presence: true
  validates :required_number_players, presence: true, numericality: { only_integer: true, greater_than: 1 }

  has_many :game_users, dependent: :destroy
  has_many :users, through: :game_users

  serialize :go_fish, JSON, type: GoFish

  def start!
    return false unless enough_players?

    players = users.map { |user| Player.new(user.id) }
    go_fish = GoFish.new(players)
    go_fish.deal!
    update(go_fish:, started_at: Time.zone.now)
  end

  def play_round!
    go_fish.play_round!
    save!
  end

  def enough_players?
    users.count == required_number_players
  end
end

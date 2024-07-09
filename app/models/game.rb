class Game < ApplicationRecord
  validates :name, presence: true
  validates :required_number_players, presence: true, numericality: { only_integer: true, greater_than: 1 }
  # TODO: Test this validation. Factory bot

  has_many :game_users, dependent: :destroy
  has_many :users, through: :game_users

  def enough_players?
    users.count == required_number_players
  end
end

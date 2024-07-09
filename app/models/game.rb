class Game < ApplicationRecord
  validates :name, presence: true
  validates :required_number_players, presence: true, numericality: { only_integer: true, greater_than: 1 }

  has_many :game_users, dependent: :destroy
  has_many :users, through: :game_users
end

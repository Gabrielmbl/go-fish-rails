class Game < ApplicationRecord
  validates :name, presence: true

  has_many :game_users
  has_many :users, through: :game_users
end

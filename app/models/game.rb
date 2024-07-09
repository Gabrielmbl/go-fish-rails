class Game < ApplicationRecord
  validates :name, presence: true

  has_many :game_users, dependent: :destroy
  has_many :users, through: :game_users
end

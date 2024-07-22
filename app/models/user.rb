class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :game_users
  has_many :games, through: :game_users

  def name
    email.split('@').first.capitalize
  end

  def total_games_played
    game_users.count
  end

  def wins
    game_users.where(winner: true).count
  end

  def losses
    total_games_played - wins
  end

  def win_rate
    return 0 if total_games_played.zero?

    (wins.to_f / total_games_played * 100).round(2)
  end
end

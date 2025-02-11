class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :game_users
  has_many :games, through: :game_users

  before_save :set_name

  def name
    email.split('@').first.capitalize
  end

  def set_name
    self.name = email.split('@').first.capitalize
  end

  def total_games_joined
    game_users.size
  end

  def total_games_completed
    games.select(&:finished_at).size
  end

  def total_time_played
    total_time = games.sum(&:duration)
    total_time.round(5)
  end

  def wins
    game_users.select(&:winner).size
  end

  def losses
    total_games_completed - wins
  end

  def win_rate
    return 0.0 if total_games_completed.zero?

    (wins.to_f / total_games_completed * 100).round(2)
  end
end

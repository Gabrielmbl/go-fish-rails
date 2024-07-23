# app/controllers/pages_controller.rb

class PagesController < ApplicationController
  skip_before_action :authenticate_user!

  def home
  end

  def stats
    @leaderboard = Leaderboard.order(win_ratio: :desc, wins: :desc)
  end
end

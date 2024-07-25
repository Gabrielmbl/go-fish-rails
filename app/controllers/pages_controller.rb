# app/controllers/pages_controller.rb

class PagesController < ApplicationController
  skip_before_action :authenticate_user!

  def home
  end

  def stats
    @q = Leaderboard.ransack(params[:q])
    @leaderboard = @q.result.order(win_ratio: :desc, wins: :desc).page(params[:page]).per(12)
  end

  def history
    @q = Game.finished.ransack(params[:q])
    @games = @q.result.order(created_at: :desc).page(params[:page]).per(12)
  end

  def status
    @q = Game.ransack(params[:q])
    @games = @q.result.order(created_at: :desc).page(params[:page]).per(12)
  end
end

# app/controllers/pages_controller.rb

class PagesController < ApplicationController
  skip_before_action :authenticate_user!

  def home
  end

  def stats
    @users = User.all
    @games = Game.all
    @game_users = GameUser.all
  end
end

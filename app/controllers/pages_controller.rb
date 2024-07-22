# app/controllers/pages_controller.rb

class PagesController < ApplicationController
  skip_before_action :authenticate_user!

  def home
  end

  def stats
    @users = User.all.sort do |a, b|
      [b.win_rate, b.wins] <=> [a.win_rate, a.wins]
    end
  end
end

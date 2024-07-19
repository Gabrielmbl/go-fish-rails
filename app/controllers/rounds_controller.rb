class RoundsController < ApplicationController
  before_action :set_game
  before_action :set_user

  def create
    @opponent_id = round_params[:opponent_id]
    @card_rank = round_params[:rank]
    @game.play_round!(@user.id, @opponent_id, @card_rank)
    redirect_to @game
  rescue GoFish::InvalidTurn, Player::InvalidOpponent => e
    flash[:danger] = e
    redirect_to @game
  end

  private

  def set_game
    @game = Game.find(params[:game_id])
  end

  def set_user
    @user = current_user
  end

  def round_params
    params.permit(:opponent_id, :rank, :game_id, :_method, :authenticity_token, :commit)
  end
end

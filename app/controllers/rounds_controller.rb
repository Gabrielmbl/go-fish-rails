class RoundsController < ApplicationController
  before_action :set_game
  before_action :set_user

  def create
    @opponent_id = round_params[:opponent_id]
    @card_rank = round_params[:rank]

    if @game.play_round!(@user.id, @opponent_id, @card_rank)
      redirect_to @game, notice: 'Round played successfully.'
    else
      redirect_to @game, alert: 'Unable to play round.'
    end
  end

  private

  def set_game
    @game = Game.find(params[:game_id])
  end

  def set_user
    @user = current_user
  end

  def round_params
    params.permit(:opponent_id, :rank)
  end
end

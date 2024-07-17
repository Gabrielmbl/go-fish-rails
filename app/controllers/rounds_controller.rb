class RoundsController < ApplicationController
  before_action :set_game
  before_action :set_user

  def create
    @opponent_id = round_params[:opponent_id]
    @card_rank = round_params[:rank]

    if @game.play_round!(@user.id, @opponent_id, @card_rank)
      respond_to do |format|
        format.html { redirect_to @game, notice: 'Round played successfully.' }
        format.turbo_stream { flash.now[:notice] = 'Round played successfully.' }
      end
    else
      respond_to do |format|
        format.html { redirect_to @game, alert: 'Unable to play round.' }
        format.turbo_stream { flash.now[:alert] = 'Unable to play round.' }
      end
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

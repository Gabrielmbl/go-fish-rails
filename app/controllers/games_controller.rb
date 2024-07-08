class GamesController < ApplicationController
  def index
    @games = Game.all
  end

  def show
    @game = Game.find(params[:id])
  end

  def new
    @game = Game.build
  end

  def create
    @game = Game.build(game_params)

    if @game.save
      respond_to do |format|
        format.html { redirect_to games_path, notice: 'Game was successfully created.' }
        format.turbo_stream { flash.now[:notice] = 'Game was successfully created.' }
      end
    else
      render :new
    end
  end

  def destroy
    @game = Game.find(params[:id])
    @game.destroy

    respond_to do |format|
      format.html { redirect_to games_path, notice: 'Game was successfully destroyed.' }
      format.turbo_stream { flash.now[:notice] = 'Game was successfully destroyed.' }
    end
  end

  private

  def game_params
    params.require(:game).permit(:name)
  end
end

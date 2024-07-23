class GamesController < ApplicationController
  def index
    @games = Game.includes(:users).ordered
    @user_games = current_user.games.includes(:users)
  end

  def show
    @game = Game.find(params[:id])
    @users = @game.users
  end

  def new
    @game = Game.build
    @path = games_path
    render layout: 'modal'
  end

  def edit
    @game = Game.find(params[:id])
    @path = game_path(@game)
    render layout: 'modal'
  end

  def create
    @game = Game.build(game_params)

    if @game.save
      @game.users << current_user
      redirect_to @game, notice: 'Game was successfully created.'
    else
      render :new, status: :unprocessable_entity, layout: 'modal'
    end
  end

  def update
    @game = Game.find(params[:id])

    if @game.update(game_params)
      redirect_to games_path, notice: 'Game was successfully updated.'
    else
      render :edit, status: :unprocessable_entity, layout: 'modal'
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
    params.require(:game).permit(:name, :required_number_players, :_method, :authenticity_token, :commit)
  end
end

class GamesController < ApplicationController
  def index
    @games = Game.all
    @user_games = current_user.games
    @other_games = Game.where.not(id: @user_games.pluck(:id))
  end

  def show
    @game = Game.find(params[:id])
    @users = @game.users
  end

  def new
    @game = Game.build
    @path = games_path
  end

  def edit
    @game = Game.find(params[:id])
    @path = game_path(@game)
  end

  def create
    @game = Game.build(game_params)

    if @game.save
      @game.users << current_user

      respond_to do |format|
        format.html { redirect_to @game, notice: 'Game was successfully created.' }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @game = Game.find(params[:id])

    if @game.update(game_params)
      respond_to do |format|
        format.html { redirect_to @game, notice: 'Game was successfully updated.' }
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @game = Game.find(params[:id])
    @game.destroy

    respond_to do |format|
      format.html { redirect_to games_path, notice: 'Game was successfully destroyed.' }
    end
  end

  private

  def game_params
    params.require(:game).permit(:name, :required_number_players)
  end
end

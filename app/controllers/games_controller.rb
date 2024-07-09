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
      respond_to do |format|
        format.html { redirect_to games_path, notice: 'Game was successfully created.' }
        format.turbo_stream { flash.now[:notice] = 'Game was successfully created.' }
      end
    else
      render :new
    end
  end

  def update
    @game = Game.find(params[:id])

    if @game.update(game_params)
      respond_to do |format|
        format.html { redirect_to @game, notice: 'Game was successfully updated.' }
        # TODO: Why does this work when I comment this line out?
        # format.turbo_stream { flash.now[:notice] = 'Game was successfully updated.' }
      end
    else
      render :edit
    end
  end

  def destroy
    @game = Game.find(params[:id])
    @game.destroy

    respond_to do |format|
      format.html { redirect_to games_path, notice: 'Game was successfully destroyed.' }
      # TODO: Same question as before. How is this working when this line is commented out?
      # format.turbo_stream { flash.now[:notice] = 'Game was successfully destroyed.' }
    end
  end

  private

  def game_params
    params.require(:game).permit(:name)
  end
end

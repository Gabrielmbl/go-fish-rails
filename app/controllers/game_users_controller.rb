class GameUsersController < ApplicationController
  def create
    @game = Game.find(params[:game_id])

    return redirect_to @game, alert: 'Unable to join.' if @game.users.include?(current_user) || @game.enough_players?

    @game_user = @game.game_users.build(user: current_user)
    if @game_user.save
      @game.start!
      redirect_to @game, notice: 'You have joined the game.'
    else
      redirect_to games_path, alert: 'Unable to join the game.'
    end
  end

  def destroy
    @game = Game.find(params[:game_id])
    @game_user = @game.game_users.find_by(user: current_user)

    if @game_user.destroy
      redirect_to games_path, notice: 'You have left the game.'
    else
      redirect_to @game, alert: 'Unable to leave the game.'
    end
  end
end

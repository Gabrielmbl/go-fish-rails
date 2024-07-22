class AddDefaultValueToWinnerInGameUsers < ActiveRecord::Migration[7.1]
  def change
    change_column_default :game_users, :winner, false
  end
end

class AddWinnerToGameUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :game_users, :winner, :boolean
  end
end

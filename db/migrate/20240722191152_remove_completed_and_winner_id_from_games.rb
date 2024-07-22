class RemoveCompletedAndWinnerIdFromGames < ActiveRecord::Migration[7.1]
  def change
    remove_column :games, :completed, :boolean
    remove_column :games, :winner_id, :integer
  end
end

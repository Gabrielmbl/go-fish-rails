class AddCompletedAndWinnerIdToGames < ActiveRecord::Migration[7.1]
  def change
    add_column :games, :completed, :boolean
    add_column :games, :winner_id, :integer
  end
end

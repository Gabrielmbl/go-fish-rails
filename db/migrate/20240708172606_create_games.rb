class CreateGames < ActiveRecord::Migration[7.1]
  def change
    create_table :games do |t|
      t.string :name, null: false
      t.integer :required_number_players, null: false, default: 2
      t.timestamps
    end
  end
end

class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|
      t.string :location
      t.datetime :start_time
      t.datetime :end_time
      t.integer :game_id
      t.string :description
      t.integer :program_id
    end
  end
end

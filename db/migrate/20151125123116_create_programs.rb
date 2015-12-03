class CreatePrograms < ActiveRecord::Migration
  def change
    create_table :programs do |t|
      t.string :name
      t.string :location
      t.string :schedule_days
      t.integer :location_id
      t.integer :program_id
    end
  end
end

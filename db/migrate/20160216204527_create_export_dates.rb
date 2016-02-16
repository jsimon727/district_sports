class CreateExportDates < ActiveRecord::Migration
  def change
    create_table :export_dates do |t|
      t.datetime :start_time
      t.datetime :end_time
    end
  end
end

class CreateDockingStations < ActiveRecord::Migration[5.1]
  def change
    create_table :docking_stations do |t|
      t.string :title, null: false
      t.integer :num_docks
      t.point :latlng

      t.timestamps
    end
  end
end

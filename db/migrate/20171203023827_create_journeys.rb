class CreateJourneys < ActiveRecord::Migration[5.1]
  def change
    create_table :journeys do |t|
      t.datetime :start_time, null: false, index: true
      t.datetime :end_time, null: false, index: true
      t.integer :duration
      t.integer :bike, references: :bike, null: false, index: true
      t.integer :start_dock, references: :docking_station, null: false, index: true
      t.integer :end_dock, references: :docking_station, null: false, index: true
      t.float :distance

      t.timestamps
    end
  end
end

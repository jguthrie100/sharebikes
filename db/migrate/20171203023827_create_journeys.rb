class CreateJourneys < ActiveRecord::Migration[5.1]
  def change
    create_table :journeys do |t|
      t.datetime :start_time, null: false, index: true
      t.datetime :end_time, null: false, index: true
      t.integer :duration
      t.references :bike
      t.references :start_dock
      t.references :end_dock
      t.float :distance

      t.timestamps
    end
  end
end

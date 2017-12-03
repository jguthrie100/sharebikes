require 'csv'
require 'date'

class Journey < ApplicationRecord
  belongs_to :bike, inverse_of: :journeys
  belongs_to :start_dock, class_name: 'DockingStation', inverse_of: :journey_starts
  belongs_to :end_dock, class_name: 'DockingStation', inverse_of: :journey_ends

  def docking_stations
    DockingStation.where(id: [self.start_dock_id, self.end_dock_id])
  end

  # Imports a CSV of Santander Bike journeys
  def self.import(filename)

    return 0 if filename.blank?

    errors = Array.new


    # Data at http://cycling.data.tfl.gov.uk/

    # Loop through CSV file
    CSV.foreach(filename, :headers => true) do |row|
      
      begin
        bike = Bike.find_or_create_by!(
          id: row["Bike Id"].to_i
        )
        
        start_dock = DockingStation.create_with(
          name: row["StartStation Name"]
        ).find_or_create_by!(
          id: row["StartStation Id"].to_i
        )
        
        end_dock = DockingStation.create_with(
          title: row["EndStation Name"]
        ).find_or_create_by!(
          id: row["EndStation Id"].to_i
        )
        
        journey = Journey.create_with(
          start_time: DateTime.parse(row["Start Date"]),
          end_time: DateTime.parse(row["End Date"]),
          duration: row["duration"],
          bike: bike,
          start_dock: start_dock,
          end_dock: end_dock
        ).find_or_create_by!(
          id: row["Rental Id"].to_i
        )

      rescue
        errors.push row
      end
    end
  end
end

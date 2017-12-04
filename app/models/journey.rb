require 'csv'
require 'open-uri'
require 'date'
require 'activerecord-import'

class Journey < ApplicationRecord
  belongs_to :bike, inverse_of: :journeys
  belongs_to :start_dock, class_name: 'DockingStation', inverse_of: :journey_starts
  belongs_to :end_dock, class_name: 'DockingStation', inverse_of: :journey_ends

  MIN_BIKE_POINTS_THRESHOLD = 700

  def docking_stations
    DockingStation.where(id: [self.start_dock_id, self.end_dock_id])
  end

  # Imports a CSV of Santander Bike journeys
  def self.import_csv(opts)

    filename = opts[:filename]
    update_all_docks = opts[:update_all_docks]

    return 0 if filename.blank?

    errors = Array.new
    missing_docks = []

    # Data at http://cycling.data.tfl.gov.uk/
    DockingStation.add_docking_stations if update_all_docks || DockingStation.count < MIN_BIKE_POINTS_THRESHOLD

    bikes = Hash.new
    docks = DockingStation.all.index_by(&:id)
    journeys = Hash.new

    # Loop through CSV file
    csv_data = open(filename)
    CSV.foreach(csv_data.path, :headers => true) do |row|

      skip = false
      9.times do |i|
        if row[i].blank?
          errors.push row
          skip = true
          break
        end
      end

      next if skip
      
      begin

        journey_id = row["Rental Id"].to_i
    
        bike_id = row["Bike Id"].to_i

        start_dock_id = row["StartStation Id"].to_i
        start_dock_title = row["StartStation Name"]
        end_dock_id = row["EndStation Id"].to_i
        end_dock_title = row["EndStation Name"]

        start_time = row["Start Date"]
        end_time = row["End Date"]
        duration = row["Duration"]


        bikes[bike_id] = bikes[bike_id] || [bike_id, 0]

        docks[start_dock_id] = docks[start_dock_id] || DockingStation.new(id: start_dock_id, title: start_dock_title, num_docks: nil, latlng: nil)
        docks[end_dock_id] = docks[end_dock_id] || DockingStation.new(id: end_dock_id, title: end_dock_title, num_docks: nil, latlng: nil)

        # Save docking station with geo coords if not already saved
        [start_dock_id, end_dock_id].each do |dock_id|
          next if missing_docks.include? dock_id
          if docks[dock_id].num_docks.blank? || docks[dock_id].latlng.blank?
            docks[dock_id].update_api_data(true, true)
          end
        end

distance = 0
        journeys[journey_id] = journeys[journey_id] || [journey_id, start_time, end_time, duration, bike_id, start_dock_id, end_dock_id, distance]

      rescue Exception => e
        if e.message.include?("The following bike point id is not recognised")
          missing_docks.push(e.message.split("_")[1].to_i)
        end
        puts "Error: #{e.message}"
        errors.push e
      end
    end

    bike_columns = [:id, :km_travelled]
    journey_columns = [:id, :start_time, :end_time, :duration, :bike_id, :start_dock_id, :end_dock_id, :distance]

    bike_values = Array.new
    bikes.each do |k,v|
      bike_values.push(v)
    end
    Bike.import bike_columns, bike_values, :validate => false, :batch_size => 10000, on_duplicate_key_ignore: true

    journey_values = Array.new
    journeys.each do |k, v|
      journey_values.push(v)
    end
    Journey.import journey_columns, journey_values, :validate => false, :batch_size => 10000, on_duplicate_key_ignore: true
  end
end

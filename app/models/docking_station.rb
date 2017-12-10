require 'net/http'

class DockingStation < ApplicationRecord
  has_many :journey_starts, class_name: 'Journey', inverse_of: :start_dock
  has_many :journey_ends, class_name: 'Journey', inverse_of: :end_dock

  #before_save :save_api_data # Check if api_data needs to be updated (i.e. if its not been set already)

  validates :id, :title, presence: true
  validates :num_docks, numericality: {greater_than_or_equal_to: 0, allow_nil: true}

  API_APP_ID = "525e99da"
  API_APP_KEY = "6ca6a458f8e9b078c3fced50db8f291a"

  def journeys
    Journey.where("start_dock_id = ? OR end_dock_id = ?", self.id, self.id)
  end

  def latlng_str
    return "" if self.latlng.nil?
    return "#{self.latlng.y}, #{self.latlng.x}"
  end

  def save_api_data
    begin
      update_api_data(false, false)
    rescue IOError => e
      puts "Tried to update Docking Station coords, but an Error was raised"
      p e
    end
  end

  def update_api_data(force_update = true, with_save = true)
    if force_update || (self.latlng.nil? || self.num_docks.nil?)
      api_uri = "https://api.tfl.gov.uk/BikePoint/BikePoints_#{self.id}&app_id=#{API_APP_ID}&app_key=#{API_APP_KEY}"

      res = Net::HTTP.get_response(URI(api_uri))
      dock_data = ActiveSupport::JSON.decode(res.body)

      if res.code.to_i != 200
        self.save! if with_save
        raise IOError, "HTTPError #{res.code} - #{dock_data["message"]}"
      end

      self.latlng = "(#{dock_data["lon"]}, #{dock_data["lat"]})"

      if dock_data["additionalProperties"][8]["key"].eql? "NbDocks"
        self.num_docks = dock_data["additionalProperties"][8]["value"]
      else
        dock_data["additionalProperties"].each do |d|
          if d["key"].eql? "NbDocks"
            self.num_docks = dock_data["additionalProperties"][8]["value"]
            break
          end
        end
      end
    end

    if with_save
      self.save!
    end
  end

  ##
  ## TODO - Update to use activerecord-import BULK import method to speed this up
  ##
  def self.add_docking_stations
    api_uri = "https://api.tfl.gov.uk/bikepoint"

    res = Net::HTTP.get_response(URI(api_uri))
    docks_data = ActiveSupport::JSON.decode(res.body)

    if res.code.to_i != 200
      raise IOError, "HTTPError #{res.code} - #{docks_data["message"]}"
    end

    docks_data.each do |dock_data|
      dock_id = dock_data["id"].sub("BikePoints_", "").to_i

      dock = DockingStation.find_or_initialize_by(id: dock_id)

      dock.title = dock_data["commonName"]
      dock.latlng = "(#{dock_data["lon"]}, #{dock_data["lat"]})"

      if dock_data["additionalProperties"][8]["key"].eql? "NbDocks"
        dock.num_docks = dock_data["additionalProperties"][8]["value"]
      else
        dock_data["additionalProperties"].each do |d|
          if d["key"].eql? "NbDocks"
            dock.num_docks = d["value"]
            break
          end
        end
      end
      dock.save!
    end
  end
end

require 'net/http'

class DockingStation < ApplicationRecord
  has_many :journey_starts, class_name: 'Journey', foreign_key: :start_dock
  has_many :journey_ends, class_name: 'Journey', foreign_key: :end_dock

  before_save :set_coords

  validates :id, :title, presence: true
  validates :num_docks, numericality: {greater_than_or_equal_to: 0, allow_nil: true}

  def journeys
    Journey.where("start_dock_id = ? OR end_dock_id = ?", self.id, self.id)
  end

  def set_coords
    if self.latlng.nil? || self.num_docks.nil?
      api_uri = "https://api.tfl.gov.uk/BikePoint/BikePoints_#{self.id}"

      dock_data = ActiveSupport::JSON.decode(Net::HTTP.get(URI(api_uri)))

      self.latlng = "(#{dock_data["lat"]}, #{dock_data["lon"]})"

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
  end
end

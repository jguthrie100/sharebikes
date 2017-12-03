class Bike < ApplicationRecord
  has_many :journeys

  validates :km_travelled, numericality: {greater_than_or_equal_to: 0, allow_nil: true}

  def add_km(num_km)
    km_travelled = self.km_travelled || 0
    self.update({km_travelled: km_travelled + num_km})
  end
end

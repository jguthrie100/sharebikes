require 'rails_helper'

RSpec.describe Bike, :type => :model do

  let(:bike) { FactoryBot.create :bike }

  describe ".new" do
    it "is valid with valid attributes" do
      expect(bike).to be_valid
    end

    it "is not valid unless km_travelled is a float greater than 0" do
      bike.km_travelled = -1
      expect(bike).to_not be_valid

      bike.km_travelled = "string"
      expect(bike).to_not be_valid

      bike.km_travelled = 0
      expect(bike).to be_valid

      bike.km_travelled = 100.4
      expect(bike).to be_valid
    end
  end
end
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

  describe ".add_km" do
    it "is not valid unless num_km is a Number >= 0" do
      expect{ bike.add_km("string") }.to raise_error(ArgumentError, "Argument must be >= 0")
      expect{ bike.add_km(-1) }.to raise_error(ArgumentError, "Argument must be >= 0")
      expect{ bike.add_km }.to raise_error(ArgumentError)

      expect(bike.add_km(23)).to eq(true)
    end

    it "saves the correct updated amount of km to the database" do
      expected_km = bike.km_travelled + 23
      bike.add_km(23)

      expect(bike.reload.km_travelled).to eq(expected_km)
    end
  end
end
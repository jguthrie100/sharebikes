require 'rails_helper'

RSpec.describe DockingStation, :type => :model do

  let(:dock) { FactoryBot.create :docking_station }

  describe ".new" do
    it "is valid with valid attributes" do
      expect(dock).to be_valid
    end

    it "is not valid with a blank title" do
      dock.title = ""
      expect(dock).to_not be_valid
    end

    it "expects num_docks to be greater than or equal to 0 (or nil)" do
      dock.num_docks = "string"
      expect(dock).to_not be_valid

      dock.num_docks = -1
      expect(dock).to_not be_valid

      dock.num_docks = 0
      expect(dock).to be_valid

      dock.num_docks = 100
      expect(dock).to be_valid

      dock.num_docks = nil
      expect(dock).to be_valid
    end
  end
end
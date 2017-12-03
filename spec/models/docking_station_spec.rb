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

  describe ".update_api_data" do
    context "with no params set (i.e. defaults to (true, true))" do
      it "contacts the API and overrides the existing latlng and num_docks values" do
        dock.latlng = "(1.0, 2.0)"
        dock.num_docks = 1000
        dock.save

        dock.update_api_data
        dock.reload

        expect(dock.latlng.x).to eq(-0.142207)
        expect(dock.latlng.y).to eq(51.485357)
        expect(dock.num_docks).to eq(29)
      end
    end

    context "with force_update set to false" do
      it "only updates the coords/num_docks if one of the two are blank" do
        dock.latlng = "(1.0, 2.0)"
        dock.num_docks = 1000
        dock.save

        dock.update_api_data(false)
        dock.reload

        expect(dock.latlng.x).to eq(1.0)
        expect(dock.latlng.y).to eq(2.0)
        expect(dock.num_docks).to eq(1000)
      end
    end

    context "with with_save set to false" do
      it "updates the values, but doesn't save them to the database" do
        dock.latlng = "(1.0, 2.0)"
        dock.num_docks = 1000
        dock.save

        dock.update_api_data(true, false)

        expect(dock.latlng.x).to eq(-0.142207)
        expect(dock.latlng.y).to eq(51.485357)
        expect(dock.num_docks).to eq(29)

        dock.reload

        expect(dock.latlng.x).to eq(1.0)
        expect(dock.latlng.y).to eq(2.0)
        expect(dock.num_docks).to eq(1000)
      end
    end
  end
end
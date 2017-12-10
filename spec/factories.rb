FactoryBot.define do
  factory :bike do
    id 526
    km_travelled 0
  end

  factory :docking_station do
    id 245
    title "Grosvenor Road, Pimlico"
  end

  factory :docking_station_with_coords, parent: :docking_station do
    latlng "-0.118092, 51.609865"
  end
end
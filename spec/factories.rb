FactoryBot.define do
  factory :bike do
    id 526
    km_travelled 0
  end

  factory :docking_station do
    id 245
    title "Grosvenor Road, Pimlico"
    num_docks 29
    latlng "(-0.142207, 51.485357)"
  end
end
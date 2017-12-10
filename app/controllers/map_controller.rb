require 'date'
class MapController < ApplicationController
  def index
    get_journey_data('2016-09-20T07:00', 3600)
  end

  def get_journey_data(start_time, duration)
    start_time = DateTime.parse(start_time.to_s)
    data = Journey.where("start_time >= ? AND start_time <= ?", start_time.to_s, start_time + (duration-1).seconds)

    @journeys = Hash.new

    data.each do |j|
      j_arr = @journeys[j.start_time.strftime('%FT%R')] || []
      j_arr.push([j.start_time.strftime('%FT%R'), j.end_time.strftime('%FT%R'), j.start_dock.latlng_str, j.end_dock.latlng_str])
      @journeys[j.start_time.strftime('%FT%R')] = j_arr
    end
  end
end

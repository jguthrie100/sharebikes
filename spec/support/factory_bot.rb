# spec/support/factory_bot.rb
RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods

  config.before(:each) do
### GEO REQUESTS
    stub_request(:get, "https://api.tfl.gov.uk/BikePoint/BikePoints_245").
           with(headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
           to_return(status: 200, body: File.read("./spec/support/webmock_responses/bikepoint_245_response.txt"), headers: {})
  end
end

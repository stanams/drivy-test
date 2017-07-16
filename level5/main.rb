require "json"
require "date"
require "./rental"
require "./car"

class Drivy
  attr_reader :cars, :rentals

  def initialize(data)
    @data = JSON.parse(data)
    @cars = @data["cars"].map { |car| Car.new(car["id"], car["price_per_day"], car["price_per_km"]) }
    @rentals = @data["rentals"].map do |rental|
      car = @cars.find { |car| car.id == rental["car_id"]}
      Rental.new(
        rental["id"],
        car,
        rental["deductible_reduction"],
        rental["start_date"],
        rental["end_date"],
        rental["distance"]
      )
    end
  end

  def generate_rentals
    {rentals: @rentals.map { |rental| rental.to_hash }}
  end

end

data = File.read('data.json')
puts JSON.pretty_generate(Drivy.new(data).generate_rentals)

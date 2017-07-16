require "json"
require "date"
require_relative "models/rental"
require_relative "models/car"
require_relative "models/rental_modification"

class Drivy
  attr_reader :cars, :rentals

  def initialize(data)
    @data = JSON.parse(data)
    @cars = @data["cars"].map do |car|
      Car.new(
        car["id"],
        car["price_per_day"],
        car["price_per_km"]
      )
    end
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
    @rental_modifications = @data["rental_modifications"].map do |rental_modif|
      rental_to_modify = @rentals.find { |rental| rental.id == rental_modif["rental_id"] }
      RentalModification.new(rental_to_modify, rental_modif).to_hash
    end
  end

  def generate_rentals
    {rentals: @rentals.map { |rental| rental.to_hash }}
  end

  def generate_rental_modifications
    {rental_modifications: @rental_modifications.map { |rental| rental }}
  end

end

data = File.read('data.json')
puts JSON.pretty_generate(Drivy.new(data).generate_rental_modifications)

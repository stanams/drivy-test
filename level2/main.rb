require "json"
require "date"

data = File.read('data.json')

class Drivy

  attr_reader :cars, :rentals

  def initialize(rentals, cars)
    @rentals = rentals
    @cars = cars
  end

  def calculate_prices
    output = {}
    rentals_list = []

    @rentals.each_with_index do |rental, i|
      item = {}

      number_of_days = (Date.parse(rental["end_date"]) - Date.parse(rental["start_date"]) + 1).to_i
      selected_car = @cars.find { |car| car["id"] == rental["car_id"]  }

      epoch_price = discount_price(selected_car["price_per_day"], number_of_days)
      distance_price = selected_car["price_per_km"] * rental["distance"]

      total_price = epoch_price + distance_price

      item["id"] = i + 1
      item["price"] = total_price.to_i

      rentals_list << item
    end

    output["rentals"] = rentals_list
    output
  end

  # apply the accurate discounted price to each day and sum them
  def discount_price(price_per_day, number_of_days)
    (1..number_of_days).to_a.map do |day|
       case day
       when 1
         1
       when (2..4)
         0.9
       when (4..10)
         0.7
       else
         0.5
       end
     end.inject(0) do |result, val|
      result + price_per_day * val
    end
  end

end

rentals = JSON.parse(data)["rentals"]
cars = JSON.parse(data)["cars"]
puts JSON.pretty_generate(Drivy.new(rentals, cars).calculate_prices)

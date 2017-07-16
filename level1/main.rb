require "json"
require "date"

data = File.read('data.json')

rentals = JSON.parse(data)["rentals"]
cars = JSON.parse(data)["cars"]

output = {}
rentals_list = []

rentals.each_with_index do |rental, i|
  item = {}

  number_of_days = (Date.parse(rental["end_date"]) - Date.parse(rental["start_date"]) + 1).to_i
  selected_car = cars.find { |car| car["id"] == rental["car_id"]  }

  price_per_day = selected_car["price_per_day"] * number_of_days
  price_per_km = selected_car["price_per_km"] * rental["distance"]

  total_price = price_per_km + price_per_day

  item["id"] = i + 1
  item["price"] = total_price.to_i

  rentals_list << item
end

output["rentals"] = rentals_list
puts JSON.pretty_generate(output)

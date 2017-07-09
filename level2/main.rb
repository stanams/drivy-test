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
      item["price"] = total_price

      rentals_list << item
    end

    output["rentals"] = rentals_list
  end

  def discount_price(price_per_day, number_of_days)
    price_after_one_day_discount = 0.9 * price_per_day
    price_after_four_days_discount = 0.7 * price_per_day
    price_after_ten_days_discount = 0.5 * price_per_day

    if (2...4).include?(number_of_days)
      discounted_price = 0.9 * price_per_day
      return price_per_day + discounted_price * (number_of_days - 1)
    elsif (4..10).include?(number_of_days)
      discounted_price = 0.7 * price_per_day
      return price_per_day + price_after_one_day_discount * 3 + discounted_price * (number_of_days - 4)
    elsif (number_of_days > 10)
      discounted_price = 0.5 * price_per_day
      return price_per_day + price_after_one_day_discount * 3 + price_after_four_days_discount * 6 + discounted_price * (number_of_days - 10)
    else
      return price_per_day * number_of_days
    end
  end
end

rentals = JSON.parse(data)["rentals"]
cars = JSON.parse(data)["cars"]
puts Drivy.new(rentals, cars).calculate_prices

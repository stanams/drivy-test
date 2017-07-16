require "json"
require "date"
require "./commission.rb"
require "./rental_options.rb"
require "./actions.rb"

data = File.read('data.json')

class Rental

  attr_reader :cars, :rentals
  attr_accessor :output

  def initialize(rentals, cars, actions = [], output = {})
    @rentals = rentals
    @cars = cars
    @actions = actions
    @output = output
  end

  def calculate_prices
    rentals_list = []

    @rentals.each_with_index do |rental, i|
      item = {}

      number_of_days = (Date.parse(rental["end_date"]) - Date.parse(rental["start_date"]) + 1).to_i

      selected_car = @cars.find { |car| car["id"] == rental["car_id"]  }

      epoch_price = discount_price(selected_car["price_per_day"], number_of_days)
      distance_price = selected_car["price_per_km"] * rental["distance"]

      total_price = epoch_price + distance_price

      item["id"] = i + 1
      deductible_reduction = RentalOptions.new(number_of_days, rental["deductible_reduction"]).calculate

      item["actions"] = generate_actions(total_price, deductible_reduction, number_of_days)
      rentals_list << item

    end
    @output["rentals"] = rentals_list
    @output.to_json
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

  def generate_actions(total_price, deductible_reduction, days)
    comm = Commission.new(total_price, days)
    owner_credit = total_price - comm.commission_amount
    [
      Actions.new('driver', 'debit', total_price + deductible_reduction).to_hash,
      Actions.new('owner', 'credit', owner_credit).to_hash,
      Actions.new('insurance', 'credit', comm.insurance_fee).to_hash,
      Actions.new('assistance', 'credit', comm.assistance_fee).to_hash,
      Actions.new('drivy', 'credit', comm.drivy_fee + deductible_reduction).to_hash
    ]
  end

end


rentals = JSON.parse(data)["rentals"]
cars = JSON.parse(data)["cars"]
puts Rental.new(rentals, cars).calculate_prices

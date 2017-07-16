class Rental

  attr_reader :cars, :rentals
  attr_accessor :output

  def initialize(rentals, cars, deductible_reduction, actions, output = {})
    @rentals = rentals
    @cars = cars
    @deductible_reduction = deductible_reduction
    @actions = []
    @output = output
  end

  def calculate_prices
    @output["rentals"] = []

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
      @output["rentals"] << item
    end

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
    commissions = Commission.new(total_price, days)
    @actions << Actions.new('driver', 'debit',  total_price + deductible_reduction)
    @actions << Actions.new('owner', 'credit',  total_price - deductible_reduction - commissions.commission_amount)
    @actions << Actions.new('insurance', 'credit',  commissions.insurance_fee)
    @actions << Actions.new('assistance', 'credit',  commissions.assistance_fee)
    @actions << Actions.new('drivy', 'credit',  commissions.insurance_fee)

  end

end

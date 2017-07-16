require "./commission.rb"
require "./rental_options.rb"
require "./action.rb"

class Rental

  attr_reader :id, :car, :deductible_reduction
  attr_accessor :start_date, :end_date, :distance

  def initialize(id, car, deductible_reduction, start_date, end_date, distance)
    @id = id
    @car = car
    @deductible_reduction = deductible_reduction
    @start_date = start_date
    @end_date = end_date
    @distance = distance
    @actions = []
  end

  def to_hash
    {id: @id, actions: generate_actions}
  end

  # apply the accurate discounted price to each day and sum them
  def calculate_price(price_per_day, number_of_days)
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

  def get_days
    (Date.parse(@end_date) - Date.parse(@start_date)).to_i + 1
  end

  def epoch_price
    calculate_price(@car.price_per_day, get_days).to_i
  end

  def distance_price
    (@car.price_per_km * @distance).to_i
  end

  def total_price
    (epoch_price + distance_price).to_i
  end

  def deductible_reduction
    RentalOptions.new(get_days, @deductible_reduction).calculate
  end

  def generate_actions
    commissions = Commission.new(total_price, get_days)
    @actions = [
      Action.new('driver', 'debit',  total_price + deductible_reduction).to_hash,
      Action.new('owner', 'credit',  total_price - commissions.commission_amount).to_hash,
      Action.new('insurance', 'credit',  commissions.insurance_fee).to_hash,
      Action.new('assistance', 'credit',  commissions.assistance_fee).to_hash,
      Action.new('drivy', 'credit',  deductible_reduction + commissions.drivy_fee).to_hash
    ]
  end

end

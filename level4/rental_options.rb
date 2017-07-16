class RentalOptions

  DEDUCTIBLE_AMOUNT = 400

  def initialize(days, has_subscribe_to_deductible)
    @days = days
    @has_subscribe_to_deductible = has_subscribe_to_deductible
  end

  def calculate
    @has_subscribe_to_deductible ? @days * DEDUCTIBLE_AMOUNT : 0
  end

  def to_json
    {
      "deductible_reduction": calculate.to_i
    }
  end

end

class RentalOptions

  DEDUCTIBLE_AMOUNT = 400

  def initialize(days, has_subscribe_to_deductible)
    @days = days
    @has_subscribe_to_deductible = has_subscribe_to_deductible
  end

  def calculate
    @has_subscribe_to_deductible ? @days * DEDUCTIBLE_AMOUNT : 0
  end

  def generate
    {
      "deductible_reduction": @has_subscribe_to_deductible ? @days * DEDUCTIBLE_AMOUNT : 0
    }
  end

end

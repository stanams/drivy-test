class RentalOptions
  DEDUCTIBLE_AMOUNT = 400

  attr_reader :days, :has_subscribe_to_deductible_reduction
  def initialize(days, has_subscribe_to_deductible_reduction)
    @days = days
    @has_subscribe_to_deductible_reduction = has_subscribe_to_deductible_reduction
  end

  def calculate
    @has_subscribe_to_deductible_reduction ? @days * DEDUCTIBLE_AMOUNT : 0
  end

  def generate
    {
      "deductible_reduction": calculate
    }
  end

end

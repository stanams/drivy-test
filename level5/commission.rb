class Commission

  attr_reader :amount, :days

  COMMISSION_RATE = 0.3
  INSURANCE_FEE = 0.5
  ASSISTANCE = 100

  def initialize(rental_price, days)
    @rental_price = rental_price
    @days = days
  end

  def commission_amount
    @rental_price * COMMISSION_RATE
  end

  def distribute_commission_fees
    {
      "insurance_fee": insurance_fee,
      "assistance_fee": assistance_fee,
      "drivy_fee": drivy_fee
    }
  end

  def insurance_fee
    INSURANCE_FEE * commission_amount
  end

  def assistance_fee
    ASSISTANCE * @days
  end

  def drivy_fee
    commission_amount - insurance_fee - assistance_fee
  end
end

class Actions
  def initialize(who, type, amount)
    @who = who
    @type = type
    @amount = amount
  end

  def to_hash
    {who: @who, type: @type, amount: @amount}
  end

end

class RentalModification

  attr_reader :old_rental, :rental_modifications

  def initialize(old_rental, rental_modifications)
    @old_rental = old_rental
    @rental_modifications = rental_modifications
  end

  def calculate_new_rental
    Rental.new(
        @old_rental.id,
        @old_rental.car,
        @old_rental.deductible_reduction,
        new_start_date || @old_rental.start_date,
        new_end_date || @old_rental.end_date,
        new_distance || @old_rental.distance
      )
  end

  def generate_new_actions
    calculate_new_rental.generate_actions
  end

  def to_hash
    {
      id: @rental_modifications["id"],
      rental_id: @rental_modifications["rental_id"],
      actions: generate_delta_actions
    }
  end

  def generate_delta_actions
    generate_new_actions.map.with_index do |new_action_hash, i|
      if new_action_hash[:amount] - @old_rental.generate_actions[i][:amount] < 0
        new_action_hash = {
          who: new_action_hash[:who],
          type: new_action_hash[:type] == "credit" ? "debit" : "credit",
          amount: @old_rental.generate_actions[i][:amount] - new_action_hash[:amount]
        }

      else
        new_action_hash = {
          who: new_action_hash[:who],
          type: new_action_hash[:type],
          amount: new_action_hash[:amount] - @old_rental.generate_actions[i][:amount]
        }
      end
    end
  end

  def new_start_date
    @rental_modifications["start_date"]
  end

  def new_end_date
    @rental_modifications["end_date"]
  end

  def new_distance
    @rental_modifications["distance"]
  end

end

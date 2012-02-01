class Expense

  def amount
    @amount ||= 0.0
  end
  
  def amount=(new_amount)
    @amount = new_amount.to_f
  end

  # Can be either :yearly or :monthly
  attr_reader :frequency

  def frequency=(new_frequency)
    @frequency = new_frequency.to_sym
  end

  # This should be a Hash { day: 5, month: 12 }
  attr_writer :occurs_on

  def occurs_on
    @occurs_on ||= { day: nil, month: nil }
  end

  def initialize(attributes = nil)
    if attributes.respond_to?(:each_pair)
      attributes.each_pair do |attr_name, attr_value|
        send("#{attr_name}=", attr_value)
      end
    end
  end
end

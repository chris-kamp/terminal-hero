# A custom error raised when providing user input that does not meet validation requirements
class InvalidInputError < StandardError
  def initialize(msg: "Invalid input provided.", requirements: "Input must meet validation requirements.")
    super(msg)
    @msg = msg
    @requirements = requirements
  end
  def to_s
    super
    "#{@msg} #{@requirements}"
  end
end

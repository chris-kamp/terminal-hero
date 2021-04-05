# A custom error raised when providing user input that does not meet validation requirements
class InvalidInputError < StandardError
  def initialize(msg: "Invalid input provided.", requirements: "Please provide valid input.")
    super(msg)
    @msg = msg
    @requirements = requirements
  end
  def to_s
    super
    print "#{@msg} #{@requirements}"
  end
end

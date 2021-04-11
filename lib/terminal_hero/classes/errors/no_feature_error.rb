# A custom error raised when accessing a feature not yet implemented
class NoFeatureError < StandardError
  def initialize(
    msg = "Sorry, it looks like you're trying to access a feature that hasn't been implemented yet. "\
    "Try choosing something else!"
  )
    super
  end
end

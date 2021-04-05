# Represents a terrain or entity tile on the map

class Tile
  attr_reader :blocking, :event, :symbol

  def initialize(symbol: "?", color: :default, blocking: false, event: nil)
    @symbol = symbol
    @color = color
    @blocking = blocking
    @event = event
  end

  def to_s
    return @symbol.colorize(@color)
  end
end

# Represents a terrain or entity tile on the map

class Tile
  attr_reader :blocking, :event, :symbol

  def initialize(symbol: "?", color: :default, blocking: false, event: nil, monster: nil)
    @symbol = symbol
    @color = color
    @blocking = blocking
    @event = event
    @monster = monster
  end

  def to_s
    return @symbol.colorize(@color)
  end
end

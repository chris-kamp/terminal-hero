# Represents a terrain or entity tile on the map

class Tile
  attr_reader :blocking, :event, :symbol

  def initialize(symbol: "?", color: :default, blocking: false, event: nil, description: "Unknown")
    @symbol = symbol
    @color = color
    @blocking = blocking
    @event = event
    @description = description
  end
  def to_s
    return @symbol.colorize(@color)
  end

  # Export all values required for initialization to a hash, to be stored in a JSON save file
  def export
    return {
      symbol: @symbol,
      color: @color,
      blocking: @blocking,
      event: @event,
      description: @description
    }
  end
end

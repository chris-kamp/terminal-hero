# Represents a terrain or entity tile on the map
class Tile
  attr_reader :blocking

  def initialize(symbol, color, blocking: false)
    @symbol = symbol
    @color = color
    @blocking = blocking
  end

  def to_s
    return @symbol.colorize(@color)
  end
end

# Represents a terrain or entity tile on the map
class Tile
  attr_accessor :blocking, :event
  attr_reader :symbol, :entity

  def initialize(symbol: "?", color: :default, blocking: false, event: nil, entity: nil)
    @symbol = symbol.colorize(color)
    @color = color
    @blocking = blocking
    @event = event
    @entity = entity
  end

  # If the tile is unoccupied, return its display icon. Otherwise, return the occupant's icon.
  def to_s
    return @symbol if @entity.nil?

    return @entity.avatar
  end

  # Customer setter to set (or remove) the entity occupying a tile and update
  # the tile's properties accordingly
  def entity=(new_entity)
    if new_entity.nil?
      @entity = nil
      @event = nil
      @blocking = false
    else
      @entity = new_entity
      @blocking = true
      @event = new_entity.respond_to?(:event) ? new_entity.event : nil
    end
  end

  # Export all values required for initialization to a hash, to be stored in a JSON save file
  def export
    return {
      symbol: @symbol,
      color: @color,
      blocking: @blocking,
      event: @event,
      entity: @entity.nil? || @entity.instance_of?(Player) ? nil : @entity.export
    }
  end
end

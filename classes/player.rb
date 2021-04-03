require_relative "../modules/game_data"

# Represents the player's character
class Player
  include GameData

  attr_accessor :coords
  attr_writer :map

  def initialize(coords: GameData::DEFAULT_COORDS)
    @coords = coords

    # Player is instantiated before Map but requires a reference to it,
    # so @map is assigned manually after initialization
    @map = nil
  end

  # Given a direction to move, return the destination coords
  def move(direction)
    return {
      x: @coords[:x] + GameData::MOVE_KEYS[direction][:x],
      y: @coords[:y] + GameData::MOVE_KEYS[direction][:y]
    }
  end
end

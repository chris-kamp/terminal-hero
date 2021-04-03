
# Represents the player's character
class Player
  attr_reader :coords

  def initialize(coords = { x: 2, y: 2 })
    @coords = coords

    # Index of coord changes when moving in each direction
    @move_index = {
      left: { x: -1, y: 0 },
      right: { x: 1, y: 0 },
      up: { x: 0, y: -1 },
      down: { x: 0, y: 1 }
    }
  end

  # Given a direction to move, return the destination coords
  def move(direction)
    return {
      x: @coords[:x] + @move_index[direction][:x],
      y: @coords[:y] + @move_index[direction][:y]
    }
  end
end
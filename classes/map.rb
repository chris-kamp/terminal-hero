require 'remedy'

# Represents a map for the player to navigate
class Map
  attr_reader :grid

  def initialize(player)
    @player = player
    @grid = setup_grid

    # Store the tile the player is standing on
    @under_player = @grid[@player.coords[:y]][@player.coords[:x]]

    # Place the player on the map
    @grid[@player.coords[:y]][@player.coords[:x]] = "@"

  end

  # Populate the map grid with default values
  def setup_grid
    grid = []
    10.times { grid.push([]) }
    grid.each do |row|
      10.times do
        row.push("X")
      end
    end
    return grid
  end

end

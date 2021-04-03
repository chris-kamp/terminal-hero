require 'remedy'

# Represents a map for the player to navigate
class Map
  attr_reader :grid

  def initialize(player, width = 10, height = 10)
    # Set dimensions of map
    @width = width
    @height = height

    @player = player
    @grid = setup_grid

    # Store the tile the player is standing on
    @under_player = @grid[@player.coords[:y]][@player.coords[:x]]

    # Place the player on the map
    @grid[@player.coords[:y]][@player.coords[:x]] = @player.symbol

  end

  # Populate the map grid with default values
  def setup_grid
    grid = []
    @height.times { grid.push([]) }
    grid.each do |row|
      @width.times do
        row.push("X")
      end
    end
    return grid
  end

  # Given destination coords for player movement, update the map and move the player
  def update_map(new_coords)
    return false unless validate_move(new_coords)

    @grid[@player.coords[:y]][@player.coords[:x]] = @under_player
    @under_player = @grid[new_coords[:y]][new_coords[:x]]
    @grid[new_coords[:y]][new_coords[:x]] = @player.symbol
    @player.coords = new_coords
  end

  # Private methods for internal use below
  private

  # Check if destination coords are valid for player movement
  def validate_move(coords)
    return false unless coords.is_a?(Hash)
    return false unless (0..(@width - 1)).include?(coords[:x])
    return false unless (0..(@height - 1)).include?(coords[:y])

    return true
  end
end

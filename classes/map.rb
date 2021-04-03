require "colorize"
require_relative "tile"

# Represents a map for the player to navigate
class Map
  attr_reader :grid, :under_player, :symbols

  def initialize(player, width = 10, height = 10)
    # Set dimensions of map
    @width = width
    @height = height
    # Dictionary of map symbols
    @symbols = {
      player: Tile.new("@", :blue),
      forest: Tile.new("T", :green),
      mountain: Tile.new("M", :light_black),
      plain: Tile.new("P", :light_yellow),
      edge: Tile.new("|", :default, blocking: true)
    }
    @player = player
    @grid = setup_grid

    # Store the tile the player is standing on
    @under_player = @grid[@player.coords[:y]][@player.coords[:x]]

    # Place the player on the map
    @grid[@player.coords[:y]][@player.coords[:x]] = @symbols[:player]

  end

  # Populate the map grid with default values
  def setup_grid
    grid = []
    @height.times { grid.push([]) }
    grid.each_with_index do |row, row_index|
      row.push(@symbols[:edge])
      (@width - 2).times do
        case row_index
        when 0, (@height - 1)
          row.push(@symbols[:edge])
        when 1..3
          row.push(@symbols[:forest])
        when 4..6
          row.push(@symbols[:mountain])
        else
          row.push(@symbols[:plain])
        end
      end
      row.push(@symbols[:edge])
    end
    return grid
  end

  # Given destination coords for player movement, update the map and move the player
  def update_map(new_coords)
    return false unless validate_move(new_coords)

    @grid[@player.coords[:y]][@player.coords[:x]] = @under_player
    @under_player = @grid[new_coords[:y]][new_coords[:x]]
    @grid[new_coords[:y]][new_coords[:x]] = @symbols[:player]
    @player.coords = new_coords
  end

  # Private methods for internal use below
  private

  # Check if destination coords are valid for player movement
  def validate_move(coords)
    return false unless coords.is_a?(Hash)
    return false unless (0..(@width - 1)).include?(coords[:x])
    return false unless (0..(@height - 1)).include?(coords[:y])
    return false if @grid[coords[:y]][coords[:x]].blocking

    return true
  end
end

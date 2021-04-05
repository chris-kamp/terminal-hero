require "colorize"
require_relative "tile"
require_relative "../modules/game_data"

# Represents a map for the player to navigate
class Map
  include GameData

  attr_reader :grid, :under_player, :symbols

  def initialize(player, width: GameData::MAP_WIDTH, height: GameData::MAP_HEIGHT)
    # Set dimensions of map
    @width = width
    @height = height
    # Dictionary of map symbols
    @symbols = GameData::MAP_SYMBOLS
    @player = player
    @grid = setup_grid

    # Store the tile the player is standing on
    @under_player = @grid[@player.coords[:y]][@player.coords[:x]]

    # Place the player on the map
    @grid[@player.coords[:y]][@player.coords[:x]] = Tile.new(**@symbols[:player])

  end

  # Populate the map grid with default values
  def setup_grid
    grid = []
    @height.times { grid.push([]) }
    grid.each_with_index do |row, row_index|
      if row_index == 0 || row_index == @height - 1
        @width.times do
          row.push(Tile.new(**@symbols[:edge]))
        end
      else
        row.push(Tile.new(**@symbols[:edge]))
        (@width - 2).times do
          case row_index
          when 0, (@height - 1)
            row.push(Tile.new(**@symbols[:edge]))
          when 1..3
            row.push(Tile.new(**@symbols[:forest]))
          when 4..6
            row.push(Tile.new(**@symbols[:mountain]))
          else
            row.push(Tile.new(**@symbols[:plain]))
          end
        end
        row.push(Tile.new(**@symbols[:edge]))
      end
    end
    monsters = @width * @height / 20
    until monsters == 0
      y = rand(1..(@height-2))
      x = rand(1..(@width - 2))
      unless grid[y][x].blocking
        grid[y][x] = Tile.new(**@symbols[:monster])
        monsters -= 1
      end
    end
    return grid
  end

  # Given destination coords for player movement, update the map,
  # move the player and return destination tile (or nil if invalid)
  def process_movement(new_coords)
    if valid_move?(new_coords)
      @grid[@player.coords[:y]][@player.coords[:x]] = @under_player
      @under_player = @grid[new_coords[:y]][new_coords[:x]]
      @grid[new_coords[:y]][new_coords[:x]] = Tile.new(**@symbols[:player])
      @player.coords = new_coords
    end
    begin
      return nil if new_coords[:y].negative? || new_coords[:x].negative?

      return @grid[new_coords[:y]][new_coords[:x]]
    rescue NoMethodError, TypeError
      return nil
    end
  end

  # Private methods for internal use below
  private

  # Check if destination coords are valid for player movement
  def valid_move?(coords)
    return false unless coords.is_a?(Hash)
    return false unless (0..(@width - 1)).include?(coords[:x])
    return false unless (0..(@height - 1)).include?(coords[:y])
    return false if @grid[coords[:y]][coords[:x]].blocking

    return true
  end
end

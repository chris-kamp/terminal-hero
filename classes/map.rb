require "colorize"
require_relative "tile"
require_relative "../modules/game_data"

# Represents a map for the player to navigate
class Map
  include GameData

  attr_reader :grid, :symbols

  def initialize(player: nil, width: GameData::MAP_WIDTH, height: GameData::MAP_HEIGHT, grid: nil)
    # Set dimensions of map
    @width = width
    @height = height
    # Dictionary of map symbols
    @symbols = GameData::MAP_SYMBOLS
    if grid.nil?
      @grid = setup_grid

      # Give the Player a reference to the tile beneath it
      player.tile_under = @grid[player.coords[:y]][player.coords[:x]]
      # Place the Player on the map
      @grid[player.coords[:y]][player.coords[:x]] = player.tile

      # Populate the map with monsters
      @grid = populate_monsters(@grid)
    else
      @grid = grid.map do |row|
        row.map do |tile|
          tile[:color] = tile[:color].to_sym
          tile[:event] = tile[:event].to_sym unless tile[:event].nil?
          Tile.new(**tile)
        end
      end
      under_player = player.tile_under
      under_player[:color] = under_player[:color].to_sym
      under_player[:event] = under_player[:event].to_sym unless under_player[:event].nil?
      player.tile_under = Tile.new(**under_player)
      @grid[player.coords[:y]][player.coords[:x]] = player.tile
    end
  end

  # Populate the map grid with default values
  def setup_grid
    grid = []
    @height.times { grid.push([]) }
    tile_num = 0
    grid.each_with_index do |row, row_index|
      if row_index == 0 || row_index == @height - 1
        @width.times do
          row.push(Tile.new(**@symbols[:edge]))
        end
      else
        row.push(Tile.new(**@symbols[:edge]))
        symbol = [:forest, :mountain, :plain][tile_num]
        tile_num = (tile_num + 1) % 3
        (@width - 2).times do
          case row_index
          when 0, (@height - 1)
            row.push(Tile.new(**@symbols[:edge]))
          else
            row.push(Tile.new(**@symbols[symbol]))
          end
        end
        row.push(Tile.new(**@symbols[:edge]))
      end
    end
    return grid
  end

  # Randomly populate monsters on the grid
  def populate_monsters(grid)
    monsters = @width * @height / 60
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

  # Given destination coords for movement, update the map, move the moving entity
  # and return the destination tile (or nil if destination invalid)
  def process_movement(mover, destination)
    return nil unless valid_move?(destination)

    unless @grid[destination[:y]][destination[:x]].blocking
      @grid[mover.coords[:y]][mover.coords[:x]] = mover.tile_under
      mover.tile_under = @grid[destination[:y]][destination[:x]]
      @grid[destination[:y]][destination[:x]] = mover.tile
      mover.coords = destination
    end
    return @grid[destination[:y]][destination[:x]]
  end

  # Check if coords are a valid destination within the map (but not necessarily open for movement)
  def valid_move?(coords)
    return false unless coords.is_a?(Hash)
    return false unless (0..(@width - 1)).include?(coords[:x])
    return false unless (0..(@height - 1)).include?(coords[:y])

    return true
  end

  # Export all values required for initialization to a hash, to be stored in a JSON save file
  def export
    return {
      width: @width,
      height: @height,
      grid: @grid.map do |row|
        row.map(&:export)
      end
    }
  end


end

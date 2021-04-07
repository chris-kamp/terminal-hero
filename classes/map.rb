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

  # Given an index, a centrepoint, a radius, and a modification to the radius,
  # determine whether index false inside the radius. Used for map setup.
  def in_radius?(y_index, x_index, y_centre, x_centre, v_radius, h_radius, variance)
    ((y_centre - v_radius - variance)..(y_centre + v_radius + variance)).include?(y_index) &&
      ((x_centre - h_radius - variance)..(x_centre + h_radius + variance)).include?(x_index)
  end

  # Populate the map grid with semi-randomised terrain tiles
  def setup_grid
    # Create 2D array
    grid = []
    @height.times { grid.push(Array.new(@width, false)) }

    # Set parameters for map generation - centrepoint, base radius of map regions,
    # variance and max variance from that radius
    h_cent = @width / 2
    v_cent = @height / 2
    h_rad = @width / 8
    v_rad = @height / 8
    variance = 0
    max_variance = ([@width, @height].min) / 16

    # Populate the map grid with terrain tiles
    grid.each_with_index do |row, y|
      row.map!.with_index do |_square, x|
        # First and last row and column are edge tiles
        if y == 0 || y == @height - 1 || x == 0 || x == @width - 1
          tile = Tile.new(**@symbols[:edge])
        # Tiles inside base radius (after variance) are region 1
        elsif in_radius?(y, x, v_cent, h_cent, v_rad, h_rad, variance)
          tile = Tile.new(**@symbols[:mountain])
        # Tiles not in region 1 that are inside 2 * base radius are region 2
        elsif in_radius?(y, x, v_cent, h_cent, v_rad * 2, h_rad * 2, variance)
          tile = Tile.new(**@symbols[:forest])
        # Everything else is region 3
        else
          tile = Tile.new(**@symbols[:plain])
        end
        variance = Utils.collar(0, variance + rand(-1..1), max_variance)
        tile
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

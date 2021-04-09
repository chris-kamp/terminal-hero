require "colorize"
require_relative "tile"
require_relative "../modules/game_data"
require_relative "../classes/monster"

# Represents a map for the player to navigate
class Map
  include GameData

  attr_reader :grid, :symbols

  def initialize(player: nil, width: GameData::MAP_WIDTH, height: GameData::MAP_HEIGHT, grid: nil, monsters: [])
    # Set dimensions of map
    @width = width
    @height = height
    # Dictionary of map symbols
    @symbols = GameData::MAP_SYMBOLS
    # Array of monsters on the map
    @monsters = monsters
    if grid.nil?
      generate_map(player)
    else
      load_map(grid, player)
    end
  end

  # SETUP

  # Generate a new map when starting a new game
  def generate_map(player)
    # Fill map grid with terrain tiles
    @grid = setup_grid
    # Place the Player on the map
    @grid[player.coords[:y]][player.coords[:x]].entity = player
    # Populate the map with monsters
    populate_monsters(player.level)
  end

  # Randomly populate monsters on the grid up to a fluctuating maximum population
  def populate_monsters(player_level)
    # 1/60 map tiles +/- 5 will be populated with monsters
    max_monsters = [(@width * @height / 80) + rand(-5..5), 1].max
    # Populate map until max population is reached, or number of iterations equals
    # number of map tiles (preventing infinite loop if valid tile not found)
    counter = 0
    until @monsters.length >= max_monsters || counter >= @width * @height
      y = rand(1..(@height - 2))
      x = rand(1..(@width - 2))
      unless @grid[y][x].blocking
        monster = Monster.new(coords: { x: x, y: y }, level_base: player_level)
        @grid[y][x].entity = monster
        @monsters.push(monster)
      end
      counter += 1
    end
  end

  # Given a grid from save data, load it into the @grid instance variable
  def load_grid!(grid)
    @grid = grid.map do |row|
      row.map do |tile|
        # Convert string values generated by JSON back to symbols
        tile[:color] = tile[:color].to_sym
        tile[:event] = tile[:event].to_sym unless tile[:event].nil?
        # Map each hash of tile data to a Tile
        Tile.new(**tile)
      end
    end
  end

  # Load monsters from save data into @monsters and place them on tiles in @grid
  def load_monsters!
    @monsters.map! do |monster_data|
      monster_data[:event] = monster_data[:event].to_sym
      monster = Monster.new(**monster_data)
      @grid[monster.coords[:y]][monster.coords[:x]].entity = monster
      monster
    end
  end

  # Set up the map grid using data loaded from a save file when loading the game
  def load_map(grid, player)
    load_grid!(grid)
    load_monsters!
    @grid[player.coords[:y]][player.coords[:x]].entity = player
  end

  # Given indices, centrepoints, a radius, and a modification to the radius,
  # determine whether indices fall inside the radius from the centrepoints. Used for generating terrain.
  def in_radius?(indices, centrepoints, radii, variance)
    y_index, x_index = indices
    y_centre, x_centre = centrepoints
    v_radius, h_radius = radii
    ((y_centre - v_radius - variance)..(y_centre + v_radius + variance)).include?(y_index) &&
      ((x_centre - h_radius - variance)..(x_centre + h_radius + variance)).include?(x_index)
  end

  # Calculate relevant paramaters for setup_grid
  def generate_grid_params
    # Create 2D array grid
    grid = []
    @height.times { grid.push(Array.new(@width, false)) }

    # Return parameters for map generation - centrepoints, base radius of map
    # regions, and the maximum random variance from that radius
    return grid, @width / 2, @height / 2, @width / 8, @height / 8, [@width, @height].min / 16
  end

  # Populate the map grid with terrain tiles in a semi-random distribution of
  # regions expanding from the centre of the map outwards
  def setup_grid
    grid, h_cent, v_cent, h_rad, v_rad, max_variance = generate_grid_params
    variance = 0
    # Populate the map grid with terrain tiles
    grid.each_with_index do |row, y|
      row.map!.with_index do |_square, x|
        # First and last row and column are edge tiles
        if y == 0 || y == @height - 1 || x == 0 || x == @width - 1
          tile = Tile.new(**@symbols[:edge])
        # Tiles inside base radius (after variance) are region 1
        elsif in_radius?([y, x], [v_cent, h_cent], [v_rad, h_rad], variance)
          tile = Tile.new(**@symbols[:mountain])
        # Tiles not in region 1 that are inside 2 * base radius are region 2
        elsif in_radius?([y, x], [v_cent, h_cent], [v_rad * 2, h_rad * 2], variance)
          tile = Tile.new(**@symbols[:forest])
        # Everything else is region 3
        else
          tile = Tile.new(**@symbols[:plain])
        end
        # Change the variance applied to radius so region boundaries are irregular
        variance = Utils.collar(0, variance + rand(-1..1), max_variance)
        tile
      end
    end
    return grid
  end

  # MOVEMENT PROCESSING

  # Given destination coords for movement, update the map, move the moving entity
  # and return the destination tile (or nil if destination invalid)
  def process_movement(mover, destination)
    return nil unless valid_move?(destination)

    unless @grid[destination[:y]][destination[:x]].blocking
      @grid[mover.coords[:y]][mover.coords[:x]].entity = nil
      @grid[destination[:y]][destination[:x]].entity = mover
      mover.coords = destination
    end
    return @grid[destination[:y]][destination[:x]]
  end

  # Call methods for each monster to determine the move it makes (if any) and process
  # that movement. If a monster encounters the player, return its tile to allow
  # triggering a combat event.
  def move_monsters(player_coords)
    event_tile = nil
    @monsters.each do |monster|
      destination = monster.calc_destination(monster.choose_move(player_coords))
      process_movement(monster, destination)
      event_tile = @grid[monster.coords[:y]][monster.coords[:x]] if destination == player_coords
    end
    return event_tile
  end

  # Check if coords are a valid destination within the map (but not necessarily open for movement)
  def valid_move?(coords)
    return false unless coords.is_a?(Hash)
    return false unless (0..(@width - 1)).include?(coords[:x])
    return false unless (0..(@height - 1)).include?(coords[:y])

    return true
  end

  # COMBAT OUTCOME PROCESSING

  # If player was defeated in combat, move them back to starting location (unless
  # already there), swapping positions with any entity that is currently occupying that location
  def process_combat_defeat(player)
    return if player.coords.values == GameData::DEFAULT_COORDS.values

    shifted_entity = @grid[GameData::DEFAULT_COORDS[:y]][GameData::DEFAULT_COORDS[:x]].entity
    player_location = player.coords
    @grid[GameData::DEFAULT_COORDS[:y]][GameData::DEFAULT_COORDS[:x]].entity = nil
    process_movement(player, GameData::DEFAULT_COORDS)
    process_movement(shifted_entity, player_location) unless shifted_entity.nil?
  end


  # Remove a monster from the map
  def remove_monster(monster)
    @grid[monster.coords[:y]][monster.coords[:x]].entity = nil
    @monsters.delete(monster)
  end

  # If a monster was defeated in combat, remove it and repopulate monsters
  def process_combat_victory(player, monster)
    remove_monster(monster)
    populate_monsters(player.level)
  end

  # When combat ends, call methods to update the map based on the outcome
  def post_combat(player, monster, outcome)
    case outcome
    when :victory
      process_combat_victory(player, monster)
    when :defeat
      process_combat_defeat(player)
    end
  end

  # EXPORT FOR SAVE

  # Export all values required for map initialization to a hash, to be stored in a JSON save file
  def export
    return {
      width: @width,
      height: @height,
      grid: @grid.map do |row|
        row.map(&:export)
      end,
      monsters: @monsters.map(&:export)
    }
  end
end

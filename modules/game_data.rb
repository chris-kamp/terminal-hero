require_relative "../classes/tile"

module GameData
  # World map dimensions
  MAP_WIDTH = 25
  MAP_HEIGHT = 25

  # Player default starting coords
  # .freeze used to freeze mutable object assigned to constant
  DEFAULT_COORDS = { x: 2, y: 2 }.freeze

  # World map tiles
  MAP_SYMBOLS = {
    player: Tile.new("@", :blue),
    forest: Tile.new("T", :green),
    mountain: Tile.new("M", :light_black),
    plain: Tile.new("P", :light_yellow),
    edge: Tile.new("|", :default, blocking: true)
  }

  # Keypress inputs for movement, and their associated coord changes
  MOVE_KEYS = {
    left: { x: -1, y: 0 },
    right: { x: 1, y: 0 },
    up: { x: 0, y: -1 },
    down: { x: 0, y: 1 }
  }.freeze
end

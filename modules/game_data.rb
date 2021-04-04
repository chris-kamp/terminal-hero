require_relative "../classes/tile"

module GameData
  # World map dimensions
  MAP_WIDTH = 25
  MAP_HEIGHT = 25

  # Player default starting coords
  # .freeze used to freeze mutable object assigned to constant
  DEFAULT_COORDS = { x: 2, y: 2 }.freeze

  # Default max hp for player and monsters
  PLAYER_DEFAULT_HP = 100
  MONSTER_DEFAULT_HP = 50

  # World map tiles
  MAP_SYMBOLS = {
    player: Tile.new("@", :blue),
    forest: Tile.new("T", :green),
    mountain: Tile.new("M", :light_black),
    plain: Tile.new("P", :light_yellow),
    edge: Tile.new("|", :default, blocking: true)
  }.freeze

  # Keypress inputs for movement, and their associated coord changes
  MOVE_KEYS = {
    left: { x: -1, y: 0 },
    right: { x: 1, y: 0 },
    up: { x: 0, y: -1 },
    down: { x: 0, y: 1 }
  }.freeze

  # Map render distance (field of view)
  H_VIEW_DIST = 3
  V_VIEW_DIST = 3

  # Combat menu options and their return values
  # Strings used as keys to match tty-prompt requirements
  COMBAT_MENU_OPTIONS = {
    "Attack" => :attack,
    "Use Item" => :useitem,
    "Flee" => :flee
  }.freeze

  # Actions that may be taken in combat, and their associated callbacks
  COMBAT_ACTIONS = {
    attack: ->(player, enemy) { enemy.receive_damage(player.calc_damage_dealt) }
  }

  # Strings of text that may be displayed to the user 
  # (and callbacks that return such strings with relevant parameters)
  MESSAGES = {
    not_implemented: ["Sorry, it looks like you're trying to access a feature that hasn't been implemented yet."\
    "Try choosing something else!"],

    player_attack: ->(player, enemy, damage) {
      [
        "You attacked the enemy, dealing #{damage} damage!",
        "Your health: #{player.current_hp} / #{player.max_hp} | "\
        "Enemy health: #{enemy.current_hp} / #{enemy.max_hp}"
      ]
    },

    enemy_attack: ->(player, enemy, damage) {
      [
        "The enemy attacked you, dealing #{damage} damage!",
        "Your health: #{player.current_hp} / #{player.max_hp} | "\
        "Enemy health: #{enemy.current_hp} / #{enemy.max_hp}"
      ]
    },

    combat_victory: ["You defeated the enemy!"],

    combat_defeat: ["You were defeated!"]
  }.freeze
end

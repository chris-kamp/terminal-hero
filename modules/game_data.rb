require_relative "../classes/tile"

module GameData
  # World map dimensions
  MAP_WIDTH = 50
  MAP_HEIGHT = 50

  # Player default starting coords
  # .freeze used to freeze mutable object assigned to constant
  DEFAULT_COORDS = { x: 2, y: 2 }.freeze

  # Constants for calculating XP to next level
  LEVELING_CONSTANT = 10
  LEVELING_EXPONENT = 1.6

  # World map tiles
  MAP_SYMBOLS = {
    player: Tile.new("@", :blue),
    forest: Tile.new("T", :green),
    mountain: Tile.new("M", :light_black),
    plain: Tile.new("P", :light_yellow),
    edge: Tile.new("|", :default, blocking: true),
    monster: Tile.new("%", :red, blocking: true, event: :combat)
  }.freeze

  # Keypress inputs for movement, and their associated coord changes
  MOVE_KEYS = {
    left: { x: -1, y: 0 },
    right: { x: 1, y: 0 },
    up: { x: 0, y: -1 },
    down: { x: 0, y: 1 }
  }.freeze

  # Maximum map render distance (field of view)
  MAX_H_VIEW_DIST = 25
  MAX_V_VIEW_DIST = 25

  # Combat statistics
  CREATURE_STATS =
    {
      atk: "Attack",
      dfc: "Defence",
      con: "Constitution"
    }.freeze

  # Stat points awarded at character creation and on level up
  STAT_POINTS_PER_LEVEL = 5

  # Default stats for any creature
  DEFAULT_STATS = {
    atk: {
      value: 5, name: "Attack"
    },
    dfc: {
      value: 5, name: "Defence"
    },
    con: {
      value: 5, name: "Constitution"
    }
  }.freeze

  # Title menu options and their return values
  # Strings used as keys to match tty-prompt requirements
  TITLE_MENU_OPTIONS = {
    "New Game" => :new_game,
    "Load Game" => :load_game,
    "Exit" => :exit_game
  }.freeze

  TITLE_MENU_ACTIONS = {
    new_game: ->(game_controller) { game_controller.start_character_creation },
    exit_game: ->(game_controller) { game_controller.exit_game }
  }.freeze

  # Combat menu options and their return values
  COMBAT_MENU_OPTIONS = {
    "Attack" => :player_attack,
    "Use Item" => :player_useitem,
    "Flee" => :player_flee
  }.freeze

  # Actions that may be taken in combat, and their associated callbacks
  COMBAT_ACTIONS = {
    player_attack: ->(player, enemy) { enemy.receive_damage(player.calc_damage_dealt) },

    player_flee: ->(player, enemy) { player.flee(enemy) }
  }

  COMMAND_LINE_ARGUMENTS = {
    new_game: ["-n", "--new", "new"] 
  }

  # Validation requirements for different types of user input
  VALIDATION_REQUIREMENTS = {
    character_name: "Names must contain only letters, numbers and underscores, be 3 to 15 characters in length"\
    ", and not contain spaces."
  }

  # Strings of text that may be displayed to the user 
  # (and callbacks that return such strings with relevant parameters)
  MESSAGES = {
    not_implemented: ["Sorry, it looks like you're trying to access a feature that hasn't been implemented yet."\
    "Try choosing something else!"],

    player_attack: ->(player, enemy, damage) {
      [
        "You attacked the enemy, dealing #{damage} damage!\n"\
        "Your health: #{player.current_hp} / #{player.max_hp} | "\
        "Enemy health: #{enemy.current_hp} / #{enemy.max_hp}"
      ]
    },

    enemy_attack: ->(player, enemy, damage) {
      [
        "The enemy attacked you, dealing #{damage} damage!\n"\
        "Your health: #{player.current_hp} / #{player.max_hp} | "\
        "Enemy health: #{enemy.current_hp} / #{enemy.max_hp}"
      ]
    },

    player_flee: ->(_player, _enemy, success) {
      msgs = ["You attempt to flee..."]
      msgs.push("You couldn't get away!") unless success
      return msgs
    },

    combat_victory: ->(xp) {
      msgs = ["You defeated the enemy!"]
      msgs.push xp == 1 ? "You received #{xp} experience point!" : "You received #{xp} experience points!"
      return msgs
    },

    leveled_up: ->(player, levels) {
      msgs = levels == 1 ? ["You gained #{levels} level!"] : ["You gained #{levels} levels!"]
      msgs[0] += " You are now level #{player.level}!"
      return msgs
    },

    level_progress: ->(player) { ["XP to next level: #{player.xp_progress}"] },

    combat_defeat: ["You were defeated!"],

    combat_escaped: ["You got away!"],

    exit_game: ["Thanks for playing! See you next time."]
  }.freeze
end

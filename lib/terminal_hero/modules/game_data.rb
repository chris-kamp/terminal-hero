begin
  require "colorize"
rescue LoadError => e
  # Display load errors using puts (not calling external methods which may not have been loaded)
  puts "It appears that a dependency was unable to be loaded: "
  puts e.message
  puts "Please try installing dependencies mannually by running the command "\
  "\"bundle install\" from within the installation directory."
  puts "If you installed this application as a gem, you could try reinstalling it by "\
  "running \"gem uninstall terminal_hero\" followed by \"gem install terminal_hero\""
  exit
end

# Stores game content and parameters as constants. Keeps data separate from
# logic, so that content or parameters can be added or adjusted without changing
# the substantive code.
module GameData
  # World map dimensions
  MAP_WIDTH = 50
  MAP_HEIGHT = 50

  # Maximum map render distance (field of view)
  MAX_H_VIEW_DIST = 25
  MAX_V_VIEW_DIST = 25

  # Constants for calculating XP to next level
  LEVELING_CONSTANT = 10
  LEVELING_EXPONENT = 1.6

  # Stat points awarded at character creation and on level up
  STAT_POINTS_PER_LEVEL = 5

  # Maximum variance of monster levels from player level
  MONSTER_LEVEL_VARIANCE = 1

  # Multiplier for XP lost (per player level) as compared to XP gained (when defeating a monster of the same level)
  XP_LOSS_MULTIPLIER = 0.5

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

  # Max HP of a creature is equal to its constitution times this multiplier
  CON_TO_HP = 10

  # Player default starting coords
  DEFAULT_COORDS = { x: 2, y: 2 }.freeze

  # World map tile data
  MAP_TILES = {
    player: {
      symbol: "@",
      blocking: true,
      color: :blue
    },
    forest: {
      symbol: "T",
      color: :green
    },
    mountain: {
      symbol: "M",
      color: :light_black
    },
    plain: {
      symbol: "P",
      color: :light_yellow
    },
    edge: {
      symbol: "|",
      color: :default,
      blocking: true
    },
    monster: {
      symbol: "%",
      color: :red,
      blocking: true,
      event: :combat
    }
  }.freeze

  TILE_DESCRIPTIONS = {
    player: "You, the player.",
    forest: "A forest of towering trees.",
    mountain: "Rugged, mountainous terrain.",
    plain: "Vast, empty plains.",
    edge: "An impassable wall.",
    monster: "A terrifying monster. You should fight it!"
  }.freeze

  MAP_HEADER = lambda { |player|
    [
      player.name.upcase.colorize(:light_yellow),
      "HEALTH: ".colorize(:light_white) +
        "#{player.current_hp}/#{player.max_hp}".colorize(player.health_color),
      "ATK: ".colorize(:light_white) +
        player.stats[:atk][:value].to_s.colorize(:green) +
        " DEF: ".colorize(:light_white) +
        player.stats[:dfc][:value].to_s.colorize(:green) +
        " CON: ".colorize(:light_white) +
        player.stats[:con][:value].to_s.colorize(:green),
      "LEVEL: ".colorize(:light_white) +
        player.level.to_s.colorize(:green) +
        " XP: ".colorize(:light_white) +
        player.xp_progress.to_s.colorize(:green),
      " "
    ]
  }

  # Keypress inputs for movement, and their associated coord changes
  MOVE_KEYS = {
    left: { x: -1, y: 0 },
    a: { x: -1, y: 0 },
    right: { x: 1, y: 0 },
    d: { x: 1, y: 0 },
    up: { x: 0, y: -1 },
    w: { x: 0, y: -1 },
    down: { x: 0, y: 1 },
    s: { x: 0, y: 1 },
  }.freeze

  # Keypress inputs that will attempt to save and then exit the game from the map screen
  # control_left_square_bracket is equivalent to the escape key
  EXIT_KEYS = [:q, :control_left_square_bracket].freeze

  GAME_STATES = {
    start_game: ->(game_controller, _params) { game_controller.start_game([]) },
    new_game: ->(game_controller, _params) { game_controller.tutorial },
    load_game: ->(game_controller, params) { game_controller.load_game(params) },
    exit_game: ->(game_controller, _params) { game_controller.exit_game },
    character_creation: ->(game_controller, _params) { game_controller.character_creation },
    world_map: ->(game_controller, params) { game_controller.map_loop(*params) },
    combat: ->(game_controller, params) { game_controller.combat_loop(*params) },
    post_combat: ->(game_controller, params) { game_controller.post_combat(*params) }
  }.freeze

  # Actions that may be taken in combat, and their associated callbacks
  COMBAT_ACTIONS = {
    player_attack: ->(player, enemy) { enemy.receive_damage(player.calc_damage_dealt) },

    player_flee: ->(player, enemy) { player.flee(enemy) },

    enemy_attack: ->(player, enemy) { player.receive_damage(enemy.calc_damage_dealt) }
  }.freeze

  # Title menu options and their return values
  # Strings used as keys to match tty-prompt requirements
  TITLE_MENU_OPTIONS = {
    "New Game" => :new_game,
    "Load Game" => :load_game,
    "Exit" => :exit_game
  }.freeze

  # Combat menu options and their return values
  COMBAT_MENU_OPTIONS = {
    "Attack" => :player_attack,
    "Flee" => :player_flee
  }.freeze

  COMMAND_LINE_ARGUMENTS = {
    new_game: ["-n", "--new"],
    load_game: ["-l", "--load"]
  }.freeze

  # Validation requirements to display to the user
  VALIDATION_REQUIREMENTS = {
    character_name: "Names must contain only letters, numbers and underscores, be 3 to 15 characters in length"\
    ", and not contain spaces."
  }.freeze

  PROMPTS = {
    re_load: "Would you like to try loading again?",
    overwrite_save: lambda { |name|
      "It looks like a saved game already exists for that character name. Are you "\
      "sure you want to overwrite the save file for #{name.upcase.colorize(:light_yellow)}?" },
    save_and_exit: "Would you like to exit the game? Your progress will be saved."
  }.freeze

  ASCII_ART = {
    title: lambda { |font, console_size|
      # Pad based on console and text size. Ascii text is centered horizontally,
      #  and about ~1/5 of the way down the screen vertically (leaving room for content below).
      top_pad = [(console_size.rows / 5), 0].max
      left_pad = [(console_size.cols / 2) - 22, 0].max
      return "#{"\n"*top_pad}#{font.write('Terminal'.rjust(left_pad))}\n"\
             "#{font.write('Hero'.rjust(10 + left_pad))}\n".colorize(:light_yellow)
    },
    level_up: lambda { |font, console_size| 
      top_pad = [(console_size.rows / 5), 0].max
      left_pad = [(console_size.cols / 2) - 12, 0].max
      "#{"\n"*top_pad}#{font.write('Level'.rjust(left_pad))}\n#{font.write('Up'.rjust(8 + left_pad))}\n".colorize(:light_yellow)
    }
  }

  # Arrays of strings to be displayed in turn by the display controller
  # (or callbacks generating such arrays)
  MESSAGES = {
    not_implemented: ["Sorry, it looks like you're trying to access a feature that hasn't been implemented yet."\
    "Try choosing something else!"],

    tutorial: lambda {
      msgs = []
      msgs.push "Welcome to Terminal Hero! In a moment, you will be prompted to create a character, but first,"\
      "let's go over how things work."
      msgs.push "When you enter the game, you will be presented with a map made up of the following symbols:"
      MAP_TILES.each do |key, tile|
        msgs.push "  #{tile[:symbol]} : #{TILE_DESCRIPTIONS[key]}".colorize(tile[:color])
      end
      msgs.push "You can move your character around the map using the arrow keys or \"WASD\" controls."
      msgs.push "It's a good idea to expand your terminal to full-screen, so that you can see further on the map."
      msgs.push "If you run into a monster, you will enter combat."
      msgs.push "In combat, you and the enemy will take turns to act."\
      "You will select your action each round from a list of options."
      msgs.push "Combat continues until you or the enemy loses all their hit points (HP), or you flee the battle."
      msgs.push "When you defeat an enemy, you will gain experience points (XP). When you lose, you will lose some XP"\
      " (but you won't lose levels). You will then be revived with full HP."
      msgs.push "When you gain enough XP, you will level up."
      msgs.push "Leveling up awards stat points, which you can expend to increase your combat statistics. These are:"
      msgs.push "#{'Attack'.colorize(:red)}: With higher attack, you will deal more damage in combat."
      msgs.push "#{'Defence'.colorize(:blue)}: With higher defence, you will receive less damage in combat."
      msgs.push "#{'Constitution'.colorize(:green)}: Determines your maximum HP."
      msgs.push "You can see your current level, HP and stats above the map at any time."
      msgs.push "The game will automatically save after every battle."
      msgs.push "To load a saved game, select \"load\" from the title menu and enter the name of a character with "\
      "an existing save file when prompted."
      msgs.push "Alternatively, you can pass the arguments \"-l\" or \"--load\" followed by a saved character's name"\
      "when running the game from the command line."
      msgs.push "You can also pass the arguments \"-n\" or \"--new\" to skip the title menu and "\
      "jump straight into a new game."
      msgs.push "You can press \"escape\" or \"q\" on the map screen at any time to save and exit the game."
      msgs.push "That's all there is to it. Have fun!"
      return msgs
    },

    enter_combat: ->(enemy) { ["You encountered a level #{enemy.level} #{enemy.name}!"] },

    combat_status: lambda { |player, enemy|
      [
        "Your health: #{"#{player.current_hp} / #{player.max_hp}".colorize(player.health_color)} | "\
        "Enemy health: #{"#{enemy.current_hp} / #{enemy.max_hp}".colorize(enemy.health_color)}"
      ]
    },

    player_attack: lambda { |damage|
      ["You attacked the enemy, dealing #{damage} damage!\n"]
    },

    enemy_attack: lambda { |damage|
      ["The enemy attacked you, dealing #{damage} damage!\n"]
    },

    player_flee: lambda { |success|
      msgs = ["You attempt to flee..."]
      msgs.push("You couldn't get away!") unless success
      return msgs
    },

    combat_victory: lambda { |xp|
      msgs = ["You defeated the enemy!"]
      msgs.push xp == 1 ? "You received #{xp} experience point!" : "You received #{xp} experience points!"
      return msgs
    },

    leveled_up: lambda { |player, levels| 
      msgs = levels == 1 ? ["You gained #{levels} level!"] : ["You gained #{levels} levels!"]
      msgs[0] += " You are now level #{player.level}!"
      return msgs
    },

    level_progress: ->(player) { ["XP to next level: #{player.xp_progress}"] },

    combat_defeat: ->(xp) { ["You were defeated! You lost #{xp} XP."] },

    combat_escaped: ["You got away!"],

    exit_game: ["Thanks for playing! See you next time."],

    general_error: ->(action, e, file_path, msg: "#{action} failed: an error occurred.") {
      [
        msg.colorize(:red),
        " \"#{e.message}.\"".colorize(:yellow),
        "Details of the error have been logged to \"#{file_path.colorize(:light_blue)}.\" "\
        "If you would like to submit a bug report, please include a copy of this file."
      ]
    },

    out_of_bounds_error: "You have attempted to move outside the game map. If you loaded the game,"\
      "your save file may have been modified or corrupted.".colorize(:red),

    error_hide_msg: ->(file_path) {
      [
        "Details of the error have been logged to \"#{file_path.colorize(:light_blue)}.\" "\
        "If you would like to submit a bug report, please include a copy of this file."
      ]
    },

    save_permission_error: [
      "To enable saving, please ensure that the current user has "\
      "write access to the directory where the game has been installed"\
      "and to files in the \"termina_hero/saves\" subfolder."
    ],

    no_save_file_error: [
      "No save was file found for that character. Input "\
      "must match the character's name exactly (but is not case sensitive).".colorize(:red)
    ],

    load_permission_error: [
      "To enable loading, please ensure that the current user has "\
      "read access to files in the \"terminal_hero/saves\" subfolder."
    ],

    parse_error: [
      "The save file you are trying to load could not be parsed. It may have been modified or corrupted.".colorize(:red)
    ],

    dependency_load_error: [
      "It appears that a dependency was not able to be loaded.",
      "Please try installing dependencies mannually by running the command \"bundle install\" from within the installation directory.",
      "If you installed this application as a gem, you could try reinstalling it by running \"gem uninstall terminal_hero\" followed by \"gem install terminal_hero\""
    ]
  }.freeze
end

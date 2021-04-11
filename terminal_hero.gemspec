Gem::Specification.new do |s|
  s.name = 'terminal_hero'
  s.version = '0.1.0'
  s.authors = 'Chris Kamp'
  s.files = ["lib/terminal_hero.rb", "lib/terminal_hero/classes/creature.rb", "lib/terminal_hero/classes/map.rb", "lib/terminal_hero/classes/monster.rb", "lib/terminal_hero/classes/player.rb", "lib/terminal_hero/classes/stat_menu.rb", "lib/terminal_hero/classes/tile.rb", "lib/terminal_hero/classes/errors/invalid_input_error.rb", "lib/terminal_hero/classes/errors/no_feature_error.rb", "lib/terminal_hero/modules/display_controller.rb", "lib/terminal_hero/modules/game_controller.rb", "lib/terminal_hero/modules/game_data.rb", "lib/terminal_hero/modules/input_handler.rb", "lib/terminal_hero/modules/utils.rb"]
  s.summary = 'A simple turn-based roleplaying game, playable in the terminal.'
  s.homepage = 'https://github.com/chris-kamp/terminal-hero'
  s.description = 'Terminal Hero is a simple turn-based roleplaying game, created for coursework. Players can navigate an ASCII world map, encounter monsters and fight using a turn-based combat system. There is a leveling system and players can allocate stat points to different combat attributes.'
  s.executables << 'terminal_hero'
end
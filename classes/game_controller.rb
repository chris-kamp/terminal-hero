require "remedy"
require "json"
require_relative "../modules/game_data"
require_relative "../modules/input_handler"
require_relative "player"
require_relative "map"
require_relative "monster"
require_relative "errors/no_feature_error"
require_relative "../modules/display_controller"

# Handles game loops and interactions between main objects
module GameController
  include Remedy

  # Initialise Player or Map instances using given hashes of paramaters (or if none, default values).
  def self.init_player_and_map(player_data: {}, map_data: {})
    player = Player.new(**player_data)
    map = Map.new(player: player, **map_data)
    { player: player, map: map }
  end

  # Display title menu and get user input to start, load or exit the game
  def self.start_game(command_line_args)
    action = InputHandler.process_command_line_args(command_line_args)
    if action == false
      begin
        action = DisplayController.prompt_title_menu
        # Raise a custom error indicating feature not implemented yet
        raise NoFeatureError unless GameData::TITLE_MENU_ACTIONS.keys.include?(action)
      rescue NoFeatureError => e
        DisplayController.display_messages([e.message])
        retry
      end
    end
    GameData::TITLE_MENU_ACTIONS[action].call(self)
  end

  # Ask the player if they want to view the tutorial, and if so, display it.
  # Give player the option to replay tutorial multiple times. Then, start character creation.
  def self.start_tutorial
    answer = DisplayController.prompt_tutorial
    while answer
      DisplayController.display_messages(GameData::MESSAGES[:tutorial].call)
      answer = DisplayController.prompt_tutorial(replay: true)
    end
    start_character_creation
  end

  # Get user input to create a new character by choosing a name and allocating stats.
  def self.start_character_creation
    name = DisplayController.prompt_character_name
    stats = DisplayController.prompt_stat_allocation(GameData::DEFAULT_STATS, GameData::STAT_POINTS_PER_LEVEL)
    player, map = init_player_and_map(player_data: { name: name, stats: stats }).values_at(:player, :map)
    save_game(player, map)
    map_loop(map, player)
  end


  # Display an exit message and exit the application
  def self.exit_game
    DisplayController.display_messages(GameData::MESSAGES[:exit_game])
    exit
  end

  # Calls methods to display map, listen for user input, and
  # update map accordingly
  def self.map_loop(map, player)
    DisplayController.set_resize_hook(map, player)
    DisplayController.draw_map(map, player)
    input_listener = Interaction.new
    input_listener.loop do |key|
      if GameData::MOVE_KEYS.keys.include?(key.name.to_sym)
        tile = map.process_movement(player.move(key.name.to_sym))
        DisplayController.cancel_resize_hook
        trigger_map_event(tile, player, map)
        DisplayController.set_resize_hook(map, player)
        DisplayController.draw_map(map, player)
      end
    end
  end

  # Given a destination tile, if it has an associated event, trigger that event
  def self.trigger_map_event(tile, player, map)
    begin
      event = tile.event
    rescue NoMethodError
      event = nil
    end
    return false if event.nil?

    case event
    when :combat
      DisplayController.clear
      monster = Monster.new(level_base: player.level)
      combat_loop(player, monster, map)
      return true
    end
  end

  # Calls methods to display combat action menu, get user selection,
  # process combat actions, and determine end of combat
  def self.combat_loop(player, enemy, map)
    DisplayController.display_messages(GameData::MESSAGES[:enter_combat].call(enemy))
    loop do
      action_outcome = player_act(player, enemy)
      if enemy.dead?
require "tty-logger"
        finish_combat(player, enemy, map, :victory)
        break
      elsif fled_combat?(action_outcome)
        finish_combat(player, enemy, map, :escaped)
        break
      else
        enemy_act(player, enemy)
        if player.dead?
          finish_combat(player, enemy, map, :defeat)
          break
        end
      end
    end
  end

  # Get player input and process their chosen action for a combat round
  def self.player_act(player, enemy)
    begin
      action = DisplayController.prompt_combat_action
      # Raise a custom error indicating feature not implemented
      raise NoFeatureError unless GameData::COMBAT_ACTIONS.keys.include?(action)
    rescue NoFeatureError => e
      DisplayController.display_messages([e.message])
      retry
    end
    outcome = GameData::COMBAT_ACTIONS[action].call(player, enemy)
    DisplayController.display_messages(GameData::MESSAGES[action].call(player, enemy, outcome))
    return { action: action, outcome: outcome }
  end

  # Process one round of action by an enemy in combat
  def self.enemy_act(player, enemy)
    # Placeholder damage values until stats are implemented
    damage_received = player.receive_damage(enemy.calc_damage_dealt)
    DisplayController.display_messages(GameData::MESSAGES[:enemy_attack].call(player, enemy, damage_received))
  end

  # Returns true if passed the return value of a player_act call where
  # the player attempted to flee and succeeded
  def self.fled_combat?(action_outcome)
    return action_outcome == {
      action: :player_flee,
      outcome: true
    }
  end

  # Display appropriate messages and take other required actions based on
  # the outcome of a combat encounters
  def self.finish_combat(player, enemy, map, outcome)
    case outcome
    when :victory
      xp = player.gain_xp(enemy.calc_xp)
      DisplayController.display_messages(GameData::MESSAGES[:combat_victory].call(xp))
      if player.leveled_up?
        levels = player.level_up
        DisplayController.display_messages(GameData::MESSAGES[:leveled_up].call(player, levels))
        player.allocate_stats(DisplayController.prompt_stat_allocation(player.stats, GameData::STAT_POINTS_PER_LEVEL))
      end
      DisplayController.display_messages(GameData::MESSAGES[:level_progress].call(player))
    when :defeat
      xp_loss = player.lose_xp((enemy.calc_xp * GameData::XP_LOSS_MULTIPLIER).round)
      DisplayController.display_messages(GameData::MESSAGES[:combat_defeat].call(xp_loss))
      DisplayController.display_messages(GameData::MESSAGES[:level_progress].call(player))
      player.heal_hp(player.max_hp)
    when :escaped
      DisplayController.display_messages(GameData::MESSAGES[:combat_escaped])
    end
    save_game(player, map)
    DisplayController.clear
  end

  # Save all data required to re-initialise the current game state to a file
  # If save fails, display a message to the user but allow program to continue
  def self.save_game(player, map)
    begin
      Dir.mkdir("saves") unless Dir.exist?("saves")
      file_name = "saves/#{player.name}.json"
      save_data = { player_data: player.export, map_data: map.export }
      File.write(file_name, JSON.dump(save_data))
    rescue Errno::EACCES => e
      DisplayController.display_messages(GameData::MESSAGES[:save_permission_error].call(e))
    rescue StandardError => e
      DisplayController.display_messages(GameData::MESSAGES[:generic_error].call("Autosave", e))
    end
  end

  def self.load_game
    # Implement prompt for character name
    # Need to properly handle incorrect values in prompt_save name and consequences
    character_name = DisplayController.prompt_save_name
    unless character_name == false
      save_data = JSON.parse(File.read("saves/#{character_name}.json"), symbolize_names: true)
      player, map = init_player_and_map(**{ player_data: save_data[:player_data], map_data: save_data[:map_data] }).values_at(:player, :map)
      map_loop(map, player)
    else
      start_game([])
    end
  end
end

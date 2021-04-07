require "remedy"
require "json"
require_relative "game_data"
require_relative "input_handler"
require_relative "display_controller"
require_relative "../classes/player"
require_relative "../classes/map"
require_relative "../classes/monster"
require_relative "../classes/errors/no_feature_error"

# Handles game loops and interactions between main objects
module GameController
  include Remedy

  # Given a symbol corresponding to a key in the GAME_STATES hash (and optionally
  # an array of parameters), call the associated lambda to enter that game state. 
  def self.enter(game_state, params = nil)
    GameData::GAME_STATES[game_state].call(self, params)
  end

  # Display title menu, determine the next game state based on command line
  # arguments or user input, and return a symbol representing the next game state
  def self.start_game(command_line_args)
    next_state = InputHandler.process_command_line_args(command_line_args)
    if next_state == false
      begin
        next_state = DisplayController.prompt_title_menu
        # Raise a custom error if selected option has no associated game state
        raise NoFeatureError unless GameData::GAME_STATES.keys.include?(next_state)
      rescue NoFeatureError => e
        DisplayController.display_messages([e.message])
        retry
      end
    end
    return next_state
  end

  # Ask the player if they want to view the tutorial, and if so, display it.
  # Give player the option to replay tutorial multiple times.
  # Return a symbol representing the next game state (character creation).
  def self.tutorial
    show_tutorial = DisplayController.prompt_tutorial
    while show_tutorial
      DisplayController.display_messages(GameData::MESSAGES[:tutorial].call)
      show_tutorial = DisplayController.prompt_tutorial(replay: true)
    end
    return :character_creation
  end

  # Initialise Player or Map instances using given hashes of paramaters 
  # (or if none, default values). Return a hash containing those instances.
  def self.init_player_and_map(player_data: {}, map_data: {})
    player = Player.new(**player_data)
    map = Map.new(player: player, **map_data)
    { player: player, map: map }
  end

  # Get user input to create a new character by choosing a name and
  # allocating stats. Return an array containing the next game state and
  # parameters to pass with it.
  def self.character_creation
    name = DisplayController.prompt_character_name
    stats = DisplayController.prompt_stat_allocation
    # Call method to initialise player and map, passing in player data, and assign the created instances to variables.
    player, map = init_player_and_map(player_data: { name: name, stats: stats }).values_at(:player, :map)
    return [:world_map, [map, player]]
  end

  # Display an exit message. No explicit exit statement because the main
  # application loop should end after this is called.
  def self.exit_game
    DisplayController.display_messages(GameData::MESSAGES[:exit_game])
  end

  # Calls methods to display map, listen for user input, and update map accordingly
  def self.map_loop(map, player)
    # Autosave whenever entering the map
    save_game(player, map)
    DisplayController.set_resize_hook(map, player)
    DisplayController.draw_map(map, player)
    Interaction.new.loop do |key|
      if GameData::MOVE_KEYS.keys.include?(key.name.to_sym)
        tile = map.process_movement(player.move(key.name.to_sym))
        DisplayController.draw_map(map, player)
        return [tile.event, [player, map]] unless tile.event.nil?
      end
    end
  end

  # Manages a combat encounter by calling methods to get and process player actions
  # each round, determine the outcome of a combat encounter, and pass it to the
  # post_combat game state.
  def self.combat_loop(player, map, enemy = Monster.new(level_base: player.level))
    DisplayController.clear
    DisplayController.display_messages(GameData::MESSAGES[:enter_combat].call(enemy))
    loop do
      action_outcome = player_act(player, enemy)
      if enemy.dead?
        return [:post_combat, [player, enemy, map, :victory]]
      elsif fled_combat?(action_outcome)
        return [:post_combat, [player, enemy, map, :escaped]]
      else
        enemy_act(player, enemy)
        if player.dead?
          return [:post_combat, [player, enemy, map, :defeat]]
        end
      end
    end
  end

  # Get player input and process their chosen action for a single combat round.
  def self.player_act(player, enemy)
    begin
      action = DisplayController.prompt_combat_action
      # Raise a custom error if selected option does not exist
      raise NoFeatureError unless GameData::COMBAT_ACTIONS.keys.include?(action)
    rescue NoFeatureError => e
      DisplayController.display_messages([e.message])
      retry
    end
    outcome = GameData::COMBAT_ACTIONS[action].call(player, enemy)
    DisplayController.display_messages(GameData::MESSAGES[action].call(player, enemy, outcome))
    return { action: action, outcome: outcome }
  end

  # Process one round of action by an enemy in combat.
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
  def self.post_combat(player, enemy, map, outcome)
    xp = player.post_combat(outcome, enemy)
    DisplayController.post_combat(outcome, player, xp)
    # If player leveled up, apply and display the level gain and prompt user to allocate stat points
    if player.leveled_up?
      levels = player.level_up
      DisplayController.level_up(player, levels)
      player.allocate_stats(DisplayController.prompt_stat_allocation(player.stats, GameData::STAT_POINTS_PER_LEVEL))
    end
    DisplayController.clear
    # Game state returns to the world map after combat
    return [:world_map, [map, player]]
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
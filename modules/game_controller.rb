require "remedy"
require "json"
require_relative "game_data"
require_relative "input_handler"
require_relative "display_controller"
require_relative "../classes/player"
require_relative "../classes/map"
require_relative "../classes/errors/no_feature_error"

# Handles game loops and interactions between main objects
module GameController
  include Remedy

  # Given a symbol corresponding to a key in the GAME_STATES hash (and optionally
  # an array of parameters), calls a lambda triggering the method for that game
  # state (which then returns the next game state + parameters).
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
        # If selected option has no associated game state, raise a custom error and
        # re-prompt the user
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

  # Get user input to create a new character by choosing a name and
  # allocating stats.
  def self.character_creation
    name = DisplayController.prompt_character_name
    stats = DisplayController.prompt_stat_allocation
    player, map = init_player_and_map(player_data: { name: name, stats: stats }).values_at(:player, :map)
    return [:world_map, [map, player]]
  end

  # Initialise Player or Map instances using given hashes of paramaters
  # (or if none, default values). Return a hash containing those instances.
  def self.init_player_and_map(player_data: {}, map_data: {})
    player = Player.new(**player_data)
    map = Map.new(player: player, **map_data)
    { player: player, map: map }
  end

  # Calls methods to display map, listen for user input, and update map accordingly
  def self.map_loop(map, player)
    # Autosave whenever entering the map
    save_game(player, map)
    DisplayController.set_resize_hook(map, player)
    DisplayController.draw_map(map, player)
    get_map_input(map, player)
  end

  def self.get_map_input(map, player)
    Interaction.new.loop do |key|
      next unless GameData::MOVE_KEYS.keys.include?(key.name.to_sym)

      tile = process_monster_movement(map, player)
      return [tile.event, [player, map, tile]] unless tile.nil? || tile.event.nil?

      tile = process_player_movement(map, player, key)
      return [tile.event, [player, map, tile]] unless tile.event.nil?
    end
  end

  # Process monster movements and render the map
  def self.process_monster_movement(map, player)
    tile = map.move_monsters(player.coords)
    DisplayController.draw_map(map, player)
    return tile
  end

  # Process player movement and render the map
  def self.process_player_movement(map, player, key)
    tile = map.process_movement(player, player.calc_destination(key.name.to_sym))
    DisplayController.draw_map(map, player)
    return tile
  end

  # Manages a combat encounter by calling methods to get and process participant
  # actions each round, determine when combat has ended, and return the outcome
  def self.combat_loop(player, map, tile, enemy = tile.entity)
    DisplayController.clear
    DisplayController.display_messages(GameData::MESSAGES[:enter_combat].call(enemy))
    actor = :player
    loop do
      combat_outcome = process_combat_turn(actor, player, enemy, map)
      return combat_outcome unless combat_outcome == false

      actor = actor == :enemy ? :player : :enemy
    end
  end

  # Process a turn of combat for the participant whose turn it is, and check if
  # combat has ended, returning the outcome if so
  def self.process_combat_turn(actor, player, enemy, map)
    action_outcome = actor == :player ? player_act(player, enemy) : enemy_act(player, enemy)

    return check_combat_outcome(player, enemy, map, escaped: fled_combat?(action_outcome))
  end

  # Return the outcome of a combat encounter, or false if combat has not ended
  def self.check_combat_outcome(player, enemy, map, escaped: false)
    return [:post_combat, [player, enemy, map, :defeat]] if player.dead?
    return [:post_combat, [player, enemy, map, :victory]] if enemy.dead?
    return [:post_combat, [player, enemy, map, :escaped]] if escaped

    return false
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
    map.post_combat(player, enemy, outcome)
    xp = player.post_combat(outcome, enemy)
    DisplayController.post_combat(outcome, player, xp)
    # If player leveled up, apply and display the level gain and prompt user to allocate stat points
    level_up(player) if player.leveled_up?
    DisplayController.clear
    # Game state returns to the world map after combat
    return [:world_map, [map, player]]
  end

  # Level up the player, display level up message, and enter stat allocation menu
  def self.level_up(player)
    levels = player.level_up
    DisplayController.level_up(player, levels)
    player.allocate_stats(
      DisplayController.prompt_stat_allocation(
        starting_stats: player.stats,
        starting_points: GameData::STAT_POINTS_PER_LEVEL * levels
      )
    )
  end

  # Save all data required to re-initialise the current game state to a file
  # If save fails, display a message to the user but allow program to continue
  def self.save_game(player, map)
    save_data = { player_data: player.export, map_data: map.export }
    begin
      Dir.mkdir("saves") unless Dir.exist?("saves")
      File.write(File.join("saves", "#{player.name}.json"), JSON.dump(save_data))
    rescue Errno::EACCES => e
      DisplayController.display_messages(GameData::MESSAGES[:general_error].call("Autosave", e, Utils.log_error(e)))
      DisplayController.display_messages(GameData::MESSAGES[:save_permission_error])
    rescue StandardError => e
      DisplayController.display_messages(GameData::MESSAGES[:general_error].call("Autosave", e, Utils.log_error(e)))
    end
  end

  # Prompt the user for a character name, and attempt to load a savegame file with that name
  def self.load_game
    begin
      character_name = DisplayController.prompt_save_name
      # character_name will be false if input failed validation and user chose not to retry
      return :start_game if character_name == false

      save_data = JSON.parse(File.read(File.join("saves", "#{character_name}.json")), symbolize_names: true)
    rescue Errno::ENOENT => e
      DisplayController.display_messages(GameData::MESSAGES[:no_save_file_error])
      return :start_game unless DisplayController.prompt_retry

      retry
    rescue Errno::EACCES => e
      DisplayController.display_messages(GameData::MESSAGES[:general_error].call("Loading", e, Utils.log_error(e)))
      DisplayController.display_messages(GameData::MESSAGES[:load_permission_error])
      return :start_game unless DisplayController.prompt_retry

      retry
    rescue StandardError => e
      DisplayController.display_messages(GameData::MESSAGES[:general_error].call("Loading", e, Utils.log_error(e)))
      return :start_game unless DisplayController.prompt_retry

      retry
    end

    player, map = init_player_and_map(**{ player_data: save_data[:player_data], map_data: save_data[:map_data] }).values_at(:player, :map)
    map_loop(map, player)
  end

  # Display an exit message. No explicit exit statement because the main
  # application loop should end after this is called.
  def self.exit_game
    DisplayController.display_messages(GameData::MESSAGES[:exit_game])
  end
end

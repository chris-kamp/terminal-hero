require "remedy"
require_relative "../modules/game_data"
require_relative "display_controller"
require_relative "player"
require_relative "map"
require_relative "monster"
require_relative "errors/no_feature_error"

# Handles game loops and interactions between main objects
class GameController
  include Remedy
  include GameData

  def initialize
    @player = nil
    @map = nil
    # @player = Player.new
    # @map = Map.new(@player)
    # @player.map = @map
    @display_controller = DisplayController.new
    @user_input = Interaction.new
  end

  def init_player_and_map(player_name, player_stats)
    @player = Player.new(name: player_name, stats: player_stats)
    @map = Map.new(@player)
    @player.map = @map
    # Set a hook to change the maximum render distance on the map whenever the
    # terminal is resized, ensuring content fits and preventing display errors.
    # Has to be set here because need access to map and player instances.
    Console.set_console_resized_hook! do |size|
      @display_controller.h_view_dist, @display_controller.v_view_dist = @display_controller.calc_view_distance(size)
      @display_controller.draw_map(@map, @player)
    end
  end

  # Display title menu and get user input to start, load or exit the game
  def start_game(command_line_args)
    if !command_line_args.empty? && GameData::COMMAND_LINE_ARGUMENTS[:new_game].include?(command_line_args[0].downcase)
      action = :new_game
    else
      begin
        action = @display_controller.prompt_title_menu
        # Replace this with a custom MethodNotImplemented error and display its message
        raise NoFeatureError unless GameData::TITLE_MENU_ACTIONS.keys.include?(action)
      rescue NoFeatureError => e
        @display_controller.display_messages([e.message])
        retry
      end
    end
    GameData::TITLE_MENU_ACTIONS[action].call(self)
  end

  # Get user input to create a new customised character
  def start_character_creation
    name = @display_controller.prompt_character_name
    stats = @display_controller.prompt_stat_allocation(GameData::DEFAULT_STATS, GameData::STAT_POINTS_PER_LEVEL)
    init_player_and_map(name, stats)
    map_loop(@map, @player)
  end


  # Display an exit message and exit the application
  def exit_game
    @display_controller.display_messages(GameData::MESSAGES[:exit_game])
    exit
  end

  # Calls methods to display map, listen for user input, and
  # update map accordingly
  def map_loop(map, player)
    @display_controller.draw_map(map, player)
    @user_input.loop do |key|
      if GameData::MOVE_KEYS.keys.include?(key.name.to_sym)
        tile = @map.process_movement(@player.move(key.name.to_sym))
        trigger_map_event(tile)
        @display_controller.draw_map(map, player)
      end
    end
  end

  # Given a destination tile, if it has an associated event, trigger that event
  def trigger_map_event(tile)
    begin
      event = tile.event
    rescue NoMethodError
      event = nil
    end
    return false if event.nil?

    case event
    when :combat
      @display_controller.clear
      monster = Monster.new(level_base: @player.level)
      combat_loop(@player, monster)
      return true
    end
  end

  # Calls methods to display combat action menu, get user selection,
  # process combat actions, and determine end of combat
  def combat_loop(player, enemy)
    @display_controller.display_messages(GameData::MESSAGES[:enter_combat].call(enemy))
    loop do
      action_outcome = player_act(player, enemy)
      if enemy.dead?
        finish_combat(player, enemy, :victory)
        break
      elsif fled_combat?(action_outcome)
        finish_combat(player, enemy, :escaped)
        break
      else
        enemy_act(player, enemy)
        if player.dead?
          finish_combat(player, enemy, :defeat)
          break
        end
      end
    end
  end

  # Get player input and process their chosen action for a combat round
  def player_act(player, enemy)
    begin
      action = @display_controller.prompt_combat_action
      # Replace this with a custom MethodNotImplemented error and display its message
      raise NoFeatureError unless GameData::COMBAT_ACTIONS.keys.include?(action)
    rescue NoFeatureError => e
      @display_controller.display_messages([e.message])
      retry
    end
    outcome = GameData::COMBAT_ACTIONS[action].call(player, enemy)
    @display_controller.display_messages(GameData::MESSAGES[action].call(player, enemy, outcome))
    return { action: action, outcome: outcome }
  end

  # Process one round of action by an enemy in combat
  def enemy_act(player, enemy)
    # Placeholder damage values until stats are implemented
    # receive_damage needs to return damage dealt for display
    damage_received = player.receive_damage(enemy.calc_damage_dealt)
    @display_controller.display_messages(GameData::MESSAGES[:enemy_attack].call(player, enemy, damage_received))
  end

  # Returns true if passed the return value of a player_act call where
  # the player attempted to flee and succeeded
  def fled_combat?(action_outcome)
    return action_outcome == {
      action: :player_flee,
      outcome: true
    }
  end

  # Display appropriate messages and take other required actions based on
  # the outcome of a combat encounters
  def finish_combat(player, enemy, outcome)
    case outcome
    when :victory
      xp = player.gain_xp(enemy.calc_xp)
      @display_controller.display_messages(GameData::MESSAGES[:combat_victory].call(xp))
      if player.leveled_up?
        levels = player.level_up
        @display_controller.display_messages(GameData::MESSAGES[:leveled_up].call(player, levels))
        player.allocate_stats(@display_controller.prompt_stat_allocation(player.stats, GameData::STAT_POINTS_PER_LEVEL))
      end
      @display_controller.display_messages(GameData::MESSAGES[:level_progress].call(player))
    when :defeat
      xp_loss = @player.lose_xp(enemy.calc_xp * GameData::XP_LOSS_MULTIPLIER)
      @display_controller.display_messages(GameData::MESSAGES[:combat_defeat].call(xp_loss))
      @display_controller.display_messages(GameData::MESSAGES[:level_progress].call(player))
      player.heal_hp(player.max_hp)
    when :escaped
      @display_controller.display_messages(GameData::MESSAGES[:combat_escaped])
    end
    @display_controller.clear
  end
end

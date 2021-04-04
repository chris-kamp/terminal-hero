require "remedy"
require_relative "../modules/game_data"
require_relative "display_controller"
require_relative "player"
require_relative "map"
require_relative "monster"

# Handles game loops and interactions between main objects
class GameController
  include Remedy
  include GameData

  def initialize
    @player = Player.new
    @map = Map.new(@player)
    @player.map = @map
    @display_controller = DisplayController.new(@map, @player)
    @user_input = Interaction.new
  end

  # Display title menu and get user input to start, load or exit the game
  def start_game(command_line_args)
    if !command_line_args.empty? && GameData::COMMAND_LINE_ARGUMENTS[:new_game].include?(command_line_args[0].downcase)
      action = :new_game
    else
      begin
        action = @display_controller.prompt_title_menu
        # Replace this with a custom MethodNotImplemented error and display its message
        raise StandardError unless GameData::TITLE_MENU_ACTIONS.keys.include?(action)
      rescue StandardError
        @display_controller.display_messages(GameData::MESSAGES[:not_implemented])
        retry
      end
    end
    GameData::TITLE_MENU_ACTIONS[action].call(self)
  end

  # Display an exit message and exit the application
  def exit_game
    @display_controller.display_messages(GameData::MESSAGES[:exit_game])
    exit
  end

  # Calls methods to display map, listen for user input, and
  # update map accordingly
  def map_loop
    @display_controller.draw_map
    @user_input.loop do |key|
      if GameData::MOVE_KEYS.keys.include?(key.name.to_sym)
        tile = @map.process_movement(@player.move(key.name.to_sym))
        trigger_map_event(tile)
        @display_controller.draw_map
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
      begin
        monster = tile.monster
      rescue NoMethodError
        monster = Monster.new
      end
      combat_loop(@player, monster)
      return true
    end
  end

  # Calls methods to display combat action menu, get user selection,
  # process combat actions, and determine end of combat
  def combat_loop(player, enemy)
    # Placeholders, to be removed and passed in as parameters
    # when combat_loop called from map
    loop do
      action_outcome = player_act(player, enemy)
      if enemy.dead?
        finish_combat(player, :victory)
        break
      elsif fled_combat?(action_outcome)
        finish_combat(player, :escaped)
        break
      else
        enemy_act(player, enemy)
        if player.dead?
          finish_combat(player, :defeat)
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
      raise StandardError unless GameData::COMBAT_ACTIONS.keys.include?(action)
    rescue StandardError
      @display_controller.display_messages(GameData::MESSAGES[:not_implemented])
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

  # When passed the outcome of a combat encounter, display appropriate
  # messages and take other required actions
  def finish_combat(player, outcome)
    case outcome
    when :victory
      @display_controller.display_messages(GameData::MESSAGES[:combat_victory])
    when :defeat
      @display_controller.display_messages(GameData::MESSAGES[:combat_defeat])
      player.heal_hp(player.max_hp)
    when :escaped
      @display_controller.display_messages(GameData::MESSAGES[:combat_escaped])
    end
    @display_controller.clear
  end
end

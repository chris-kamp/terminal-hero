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

  # Calls methods to display map, listen for user input, and
  # update map accordingly
  def map_loop
    @display_controller.draw_map
    @user_input.loop do |key|
      if GameData::MOVE_KEYS.keys.include?(key.name.to_sym)
        @map.update_map(@player.move(key.name.to_sym))
        @display_controller.draw_map
      end
    end
  end

  # Calls methods to display combat action menu, get user selection,
  # process combat actions, and determine end of combat
  def combat_loop
    # Placeholders, to be removed and passed in as parameters
    # when combat_loop called from map
    player = @player
    enemy = Monster.new

    loop do
      player_act(player, enemy)
      if combat_won?(enemy)
        finish_combat(player, :victory)
        break
      else
        enemy_act(player, enemy)
        if combat_lost?(player)
          finish_combat(player, :defeat)
          break
        end
      end
    end
  end

  def player_act(player, enemy)
    begin
      action = @display_controller.prompt_combat_action
      # Replace this with a custom MethodNotImplemented error and display its message
      raise StandardError unless GameData::COMBAT_ACTIONS.keys.include?(action)
    rescue StandardError
      @display_controller.display_messages(GameData::MESSAGES[:not_implemented])
      retry
    end
    damage_received = GameData::COMBAT_ACTIONS[action].call(player, enemy)
    @display_controller.display_messages(GameData::MESSAGES[:player_attack].call(player, enemy, damage_received))
  end

  def enemy_act(player, enemy)
    # Placeholder damage values until stats are implemented
    # receive_damage needs to return damage dealt for display
    damage_received = player.receive_damage(enemy.calc_damage_dealt)
    @display_controller.display_messages(GameData::MESSAGES[:enemy_attack].call(player, enemy, damage_received))
  end

  def combat_won?(enemy)
    return enemy.current_hp <= 0
  end

  def combat_lost?(player)
    return player.current_hp <= 0
  end

  def finish_combat(player, outcome)
    case outcome
    when :victory
      @display_controller.display_messages(GameData::MESSAGES[:combat_victory])
    when :defeat
      @display_controller.display_messages(GameData::MESSAGES[:combat_defeat])
      player.heal_hp(player.max_hp)
    end
  end
end

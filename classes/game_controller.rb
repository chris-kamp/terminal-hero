require "remedy"
require_relative "../modules/game_data"
require_relative "display_controller"
require_relative "player"
require_relative "map"

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
    action = @display_controller.prompt_combat_action
    p action
  end
end

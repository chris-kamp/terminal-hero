require "remedy"
require_relative "display_controller"
require_relative "player"
require_relative "map"

# Handles game loops and interactions between main objects
class GameController
  include Remedy
  
  def initialize
    @player = Player.new({ x: 2, y: 2 })
    @map = Map.new(@player, 10, 10)
    @player.map = @map
    @display_controller = DisplayController.new(@map, @player)
    @user_input = Interaction.new
  end

  def map_loop
    @display_controller.draw_map
    @user_input.loop do |key|
      if @player.move_index.keys.include?(key.name.to_sym)
        @map.update_map(@player.move(key.name.to_sym))
        @display_controller.draw_map
      end
    end
  end
end
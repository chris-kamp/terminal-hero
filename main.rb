require_relative "classes/game_controller"
require "pretty_trace/enable"

game_controller = GameController.new
game_controller.start_game(ARGV)

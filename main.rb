require_relative "modules/game_controller"

next_state = GameController.start_game(ARGV)
next_state = GameController.enter(*next_state) until next_state == :exit_game
GameController.exit_game

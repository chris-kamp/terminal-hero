# A module containing methods for processing and validating input
module InputHandler
  # Given an array of command-line arguments, return the associated action if any,
  # or else return false
  def self.process_command_line_args(
    args,
    new_game_args: GameData::COMMAND_LINE_ARGUMENTS[:new_game],
    load_game_args: GameData::COMMAND_LINE_ARGUMENTS[:load_game]
  )
    return false unless args.is_a?(Array) && !args.empty?

    args.map(&:downcase)
    return :new_game if new_game_args.include?(args[0])
    return :load_game if load_game_args.include?(args[0])

    return false
  end
end

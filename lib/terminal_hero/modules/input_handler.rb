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
    return [:load_game, args[1]] if load_game_args.include?(args[0]) && args.length > 1
    return :load_game if load_game_args.include?(args[0])

    return false
  end

  # Check if a given character name is valid for creating or loading a character
  def self.character_name_valid?(name)
    return false unless name.is_a?(String)
    return false unless (3..15).include?(name.length)
    return false unless name.match?(/^\w*$/)
    return false if name.match?(/\s/)

    return true
  end
end

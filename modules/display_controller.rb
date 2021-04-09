require "remedy"
require "tty-prompt"
require "tty-font"
require_relative "game_data"
require_relative "utils"
require_relative "../classes/errors/invalid_input_error"
require_relative "../classes/stat_menu"

# Controls the display of output to the user
module DisplayController
  include Remedy

  # Displays the title menu
  def self.prompt_title_menu
    clear
    font = TTY::Font.new(:standard)
    prompt = TTY::Prompt.new
    prompt.say(
      "#{font.write("Terminal")}\n"\
      "#{font.write("Hero".rjust(20))}\n".colorize(:light_yellow)
    )
    answer = prompt.select("What would you like to do?",
      GameData::TITLE_MENU_OPTIONS
    )
    return answer
  end

  # Prompt the user for whether to re-try a failed action
  def self.prompt_retry
    TTY::Prompt.new.select("Would you like to try loading again?") do |menu|
      menu.choice "Yes", true
      menu.choice "No", false
    end
  end

  # Prompt the user to enter a character name when creating a character
  def self.prompt_character_name
    name = TTY::Prompt.new.ask("Please enter a name for your character: ")
    begin
      unless character_name_valid?(name)
        raise InvalidInputError.new(requirements: GameData::VALIDATION_REQUIREMENTS[:character_name])
      end
    rescue InvalidInputError => e
      display_messages([e.message.colorize(:red), "Please try again.".colorize(:red)])
      retry
    end
    return name
  end

  # Prompt the user to enter a character name when attempting to load
  def self.prompt_save_name
    prompt = TTY::Prompt.new
    begin
      name = prompt.ask("Please enter the name of the character you want to load.")
      unless character_name_valid?(name)
        raise InvalidInputError.new(requirements: GameData::VALIDATION_REQUIREMENTS[:character_name])
      end
    rescue StandardError => e
      display_messages([e.message.colorize(:red)])
      return false unless prompt_retry

      retry
    end
    return name
  end

  # Ask the user whether they would like to view the tutorial
  def self.prompt_tutorial(replay: false)
    verb = replay ? "repeat" : "see"
    message = "Would you like to #{verb} the tutorial?"
    prompt = TTY::Prompt.new
    return prompt.select(message) do |menu|
      menu.default replay ? "No" : "Yes"
      menu.choice "Yes", true
      menu.choice "No", false
    end
  end

  # Check if a given character name is valid
  def self.character_name_valid?(name)
    return false unless name.is_a?(String)
    return false unless (3..15).include?(name.length)
    return false unless name.match?(/^\w*$/)
    return false if name.match?(/\s/)

    return true
  end

  # Display the stat menu to the user
  def self.display_stat_menu(stats, points, line_no, header, footer)
    screen = Viewport.new
    menu = Content.new
    lines = stats.values.map { |stat| "#{stat[:name]}: #{stat[:value]}" }
    lines[line_no] = lines[line_no].colorize(:light_blue)
    menu.lines.push " ", "Stat points remaining: #{points}", " "
    lines.each { |line| menu << line }
    screen.draw(menu, [0, 0], header, footer)
  end

  # Prompt the user to allocate stat points using a stat menu
  def self.prompt_stat_allocation(starting_stats: GameData::DEFAULT_STATS, starting_points: GameData::STAT_POINTS_PER_LEVEL)
    stat_menu = StatMenu.new(starting_stats, starting_points)
    display_stat_menu(*stat_menu.get_display_parameters)
    input = Interaction.new
    input.loop do |key|
      finished, stats = stat_menu.process_input(key.name)
      return stats if finished

      display_stat_menu(*stat_menu.get_display_parameters)
    end
  end

  # Set the map render distance to fit within a given console size
  def self.calc_view_distance(size: Console.size)
    horizontal = Utils.collar(2, size.cols / 4 - 2, GameData::MAX_H_VIEW_DIST)
    vertical = Utils.collar(2, (size.rows / 2) - 5, GameData::MAX_V_VIEW_DIST)
    return [horizontal, vertical]
  end

  # Sets a hook to draw the map (with adjusted view distance) when the console
  # is resized
  def self.set_resize_hook(map, player)
    Console.set_console_resized_hook! do |size|
      draw_map(map, player, size: size)
    end
  end

  # Cancel the console resize hook (eg. when leaving the map view)
  def self.cancel_resize_hook
    Console::Resize.default_console_resized_hook!
  end

  # Draws one frame of the visible portion of the map
  def self.draw_map(map, player, size: Console.size, view_dist: calc_view_distance(size: size))
    h_view_dist = view_dist[0]
    screen = Viewport.new
    header = Header.new
    map_display = Content.new
    header << "#{player.name}"
    header << "HEALTH: #{player.current_hp}/#{player.max_hp}"
    header << "ATK: #{player.stats[:atk][:value]} DEF: #{player.stats[:dfc][:value]} CON: #{player.stats[:con][:value]}"
    header << "LEVEL: #{player.level}  XP: #{player.xp_progress}"
    header << " "
    filter_visible(map.grid, player.coords).each do |row|
      map_display << row.join(" ")
    end
    # Pushing additional row prevents truncation in smaller terminal sizes
    map_display << " " * (h_view_dist * 2)
    screen.draw(map_display, Size.new(0, 0), header)
  end

  # Given a grid, camera co-ordinates and view distances, return 
  # a grid containing only squares within the camera's field of view
  def self.filter_visible(grid, camera_coords, size: Console.size, view_dist: calc_view_distance(size: size))
    h_view_dist, v_view_dist = view_dist
    # Filter rows outside view distance
    field_of_view = grid.map do |row|
      row.reject.with_index { |_cell, x_index| (camera_coords[:x] - x_index).abs > h_view_dist }
    end
    # Filter columns outside view distance
    field_of_view.reject!.with_index { |_row, y_index| (camera_coords[:y] - y_index).abs > v_view_dist }
    return field_of_view
  end

  # Displays the combat action selection menu
  def self.prompt_combat_action
    prompt = TTY::Prompt.new
    answer = prompt.select("What would you like to do?", GameData::COMBAT_MENU_OPTIONS)
    print "\n"
    return answer
  end

  # Displays a series of messages, waiting for keypress input to advance
  def self.display_messages(msgs)
    prompt = TTY::Prompt.new(quiet: true)
    print "\n"
    msgs.each do |msg|
      puts msg
      print "\n"
      prompt.keypress("Press any key...")
    end
  end

  # Display relevant information to the user after the end of a combat encounter.
  def self.post_combat(outcome, player, xp_amount)
    case outcome
    when :victory
      display_messages(GameData::MESSAGES[:combat_victory].call(xp_amount))
    when :defeat
      display_messages(GameData::MESSAGES[:combat_defeat].call(xp_amount))
      display_messages(GameData::MESSAGES[:level_progress].call(player))
    when :escaped
      display_messages(GameData::MESSAGES[:combat_escaped])
    end
  end

  # When the player levels up, display the number of levels gained
  def self.level_up(player, levels)
    display_messages(GameData::MESSAGES[:leveled_up].call(player, levels))
  end

  # Clear the screen (without clearing terminal history)
  def self.clear
    ANSI::Screen.safe_reset!
  end
end

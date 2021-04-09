require "remedy"
require "tty-prompt"
require "tty-font"
require_relative "game_data"
require_relative "utils"
require_relative "input_handler"
require_relative "../classes/errors/invalid_input_error"
require_relative "../classes/stat_menu"

# Controls the display of output to the user
module DisplayController
  include Remedy

  # Displays a message in an ASCII art font. Return the prompt object for use
  # with subsequent prompts.
  def self.display_ascii(msg)
    clear
    font = TTY::Font.new(:standard)
    prompt = TTY::Prompt.new
    prompt.say(msg.call(font))
    return prompt
  end

  # Displays the title menu
  def self.prompt_title_menu
    prompt = display_ascii(GameData::ASCII_ART[:title])
    return prompt.select("What would you like to do?", GameData::TITLE_MENU_OPTIONS)
  end

  # Display a series of messages, waiting for keypress input to advance
  def self.display_messages(msgs, pause: true)
    prompt = TTY::Prompt.new(quiet: true)
    print "\n"
    msgs.each do |msg|
      puts msg
      print "\n"
      prompt.keypress("Press any key...") if pause
    end
  end

  # Prompt the user to enter a character name when creating a character
  def self.prompt_character_name
    begin
      prompt = display_ascii(GameData::ASCII_ART[:title])
      name = prompt.ask("Please enter a name for your character: ")
      unless InputHandler.character_name_valid?(name)
        raise InvalidInputError.new(requirements: GameData::VALIDATION_REQUIREMENTS[:character_name])
      end
    rescue InvalidInputError => e
      display_messages([e.message.colorize(:red), "Please try again.".colorize(:red)])
      retry
    end
    return name
  end

  # Prompt the user for whether to re-try a failed action
  def self.prompt_yes_no(msg, default_no: false)
    TTY::Prompt.new.select(msg) do |menu|
      menu.default default_no ? "No" : "Yes"
      menu.choice "Yes", true
      menu.choice "No", false
    end
  end

  # Ask the user whether they would like to view the tutorial
  def self.prompt_tutorial(repeat: false)
    display_ascii(GameData::ASCII_ART[:title])
    verb = repeat ? "repeat" : "see"
    message = "Would you like to #{verb} the tutorial?"
    return prompt_yes_no(message, default_no: repeat)
  end

  # Prompt the user to enter the name of the character they want to attempt to load
  def self.prompt_save_name(name = nil)
    display_ascii(GameData::ASCII_ART[:title])
    begin
      name = TTY::Prompt.new.ask("Please enter the name of the character you want to load: ") if name.nil?
      unless InputHandler.character_name_valid?(name)
        raise InvalidInputError.new(requirements: GameData::VALIDATION_REQUIREMENTS[:character_name])
      end
    rescue StandardError => e
      display_messages([e.message.colorize(:red)])
      return false unless prompt_yes_no(GameData::PROMPTS[:re_load])

      name = nil
      retry
    end
    return name
  end

  # Display the stat point allocation menu to the user
  def self.display_stat_menu(stats, points, line_no, header, footer)
    screen = Viewport.new
    menu = Content.new
    lines = stats.values.map { |stat| "#{stat[:name]}: #{stat[:value]}" }
    lines[line_no] = lines[line_no].colorize(:light_blue)
    menu.lines.push " ", "Stat points remaining: #{points}", " "
    lines.each { |line| menu << line }
    screen.draw(menu, [0, 0], header, footer)
  end

  # Prompt the user and get their input to allocate stat points using a stat menu
  def self.prompt_stat_allocation(
    starting_stats: GameData::DEFAULT_STATS,
    starting_points: GameData::STAT_POINTS_PER_LEVEL
  )
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

  # Initialise variables required for draw_map
  def self.setup_map_view(player)
    screen = Viewport.new
    header = Header.new
    map_display = Content.new
    GameData::MAP_HEADER.call(player).each { |line| header.lines.push(line)}
    return [screen, header, map_display]
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

  # Calculate the amount of padding required to center a map view
  def self.calculate_padding(header, content, size)
    # Top padding is half of the console height minus the view height
    top_pad = (size.rows - (header.lines.length + content.lines.length)) / 2
    # Get length of the longest line of the view (to determine view width)
    view_width = [
      header.lines.map(&:uncolorize).max_by(&:length).length,
      content.lines.map(&:uncolorize).max_by(&:length).length
    ].max
    # Left padding is half of the console width minus the view width.
    left_pad = (size.cols - view_width) / 2
    return top_pad, left_pad
  end

  # Given a header, content and console size, pad the header and content to center them in the console.
  def self.center_view!(header, content, size)
    top_pad, left_pad = calculate_padding(header, content, size)
    top_pad.times { header.lines.unshift(" ") }
    content.lines.map! { |line| "#{' ' * left_pad}#{line}" }
    header.lines.map! { |line| "#{' ' * left_pad}#{line}" }
  end

  # Draws one frame of the visible portion of the map
  def self.draw_map(map, player, size: Console.size, view_dist: calc_view_distance(size: size))
    screen, header, map_display = setup_map_view(player)
    filter_visible(map.grid, player.coords).each do |row|
      map_display << row.join(" ")
    end
    # Pushing additional row prevents truncation in smaller terminal sizes
    map_display << " " * (view_dist[0] * 2)
    center_view!(header, map_display, size)
    screen.draw(map_display, Size.new(0, 0), header)
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

  # Display the combat action selection menu and return user's selection
  def self.prompt_combat_action(player, enemy)
    clear
    display_messages(GameData::MESSAGES[:combat_status].call(player, enemy), pause: false)
    prompt = TTY::Prompt.new
    answer = prompt.select("\nWhat would you like to do?", GameData::COMBAT_MENU_OPTIONS)
    print "\n"
    return answer
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
    display_ascii(GameData::ASCII_ART[:level_up])
    display_messages(GameData::MESSAGES[:leveled_up].call(player, levels))
  end

  # Clear the visible terminal display (without clearing terminal history)
  def self.clear
    ANSI::Screen.safe_reset!
  end
end

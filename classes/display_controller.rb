require "remedy"
require "tty-prompt"
require_relative "../modules/game_data"
require_relative "../modules/utils"
require_relative "errors/invalid_input_error"

# Controls the display of output to the user
class DisplayController
  include Remedy
  include GameData

  def initialize
    @h_view_dist, @v_view_dist = calc_view_distance(Console.size)
  end

  # Displays the title menu
  def prompt_title_menu
    prompt = TTY::Prompt.new
    answer = prompt.select("Welcome to Terminal Hero!", GameData::TITLE_MENU_OPTIONS)
    return answer
  end

  # Prompt the user to enter a character name
  def prompt_character_name
    prompt = TTY::Prompt.new
    begin
    name = prompt.ask("Please enter a name for your character: ")
    unless name.is_a?(String)
      raise(TypeError, "You must enter a name for your character.")
    end
    unless character_name_valid?(name)
      raise InvalidInputError.new(requirements: GameData::VALIDATION_REQUIREMENTS[:character_name])
    end
    rescue TypeError, InvalidInputError => e
      puts
      puts e.message
      puts
      retry
    end
    return name
  end

  # Check if a given character name is valid
  def character_name_valid?(name)
    return false unless (3..15).include?(name.length)
    return false unless name.match?(/^\w*$/)
    return false if name.match?(/\s/)
    return true
  end

  def display_stat_menu(stats, points, line_no, header, footer)
    screen = Viewport.new
    menu = Content.new
    lines = stats.values.map { |stat| "#{stat[:name]}: #{stat[:value]}" }
    lines[line_no] = lines[line_no].colorize(:light_blue)
    menu << " "
    menu << "Stat points remaining: #{points}"
    menu << " "
    lines.each { |line| menu << line }
    screen.draw(menu, Size.new(0, 0), header, footer)
  end

  # Prompt the user to allocate stat points
  def prompt_stat_allocation(starting_stats, starting_points)
    points = starting_points
    # Because statblock is a hash of hashes, deep clone to make an independent copy
    stats = Utils.depth_two_clone(starting_stats)
    stat_index = stats.keys
    input = Interaction.new
    header = Header.new
    header << "Please allocate your character's stat points."
    header << "Use the left and right arrow keys to assign points, and enter to confirm."
    footer = Footer.new
    line_no = 0
    last_line_no = stats.length - 1
    display_stat_menu(stats, points, line_no, header, footer)
    input.loop do |key|
      case key.name
      # Right arrow key increases highlighted stat if points available
      when :right
        if points.positive?
          points -= 1
          stats[stat_index[line_no]][:value] += 1
        end
      # Left arrow key reduces highlighted stat, but not below its starting value
      when :left
        if points < starting_points && stats[stat_index[line_no]][:value] > starting_stats[stat_index[line_no]][:value]
          points += 1
          stats[stat_index[line_no]][:value] -= 1
        end
      # Up and down arrow keys to move around list
      when :down
        line_no = Utils.collar(0, line_no + 1, last_line_no)
      when :up
        line_no = Utils.collar(0, line_no - 1, last_line_no)
      # :control_m represents carriage return
      when :control_m
        if points == 0
          return stats
        else
          footer = Footer.new
          footer << "You must allocate all stat points to continue.".colorize(:red)
        end
      end
      display_stat_menu(stats, points, line_no, header, footer)
    end
  end


  # Set the map render distance to fit within a given terminal size
  def calc_view_distance(terminal_size)
    horizontal = Utils.collar(2, terminal_size.cols / 4 - 2, GameData::MAX_H_VIEW_DIST)
    vertical = Utils.collar(2, terminal_size.rows - 10, GameData::MAX_V_VIEW_DIST)
    return [horizontal, vertical]
  end

  # Draws one frame of the visible portion of the map
  def draw_map(map, player)
    screen = Viewport.new
    header = Header.new
    map_display = Content.new
    header << "#{player.name}"
    header << "HEALTH: #{player.current_hp}/#{player.max_hp}"
    header << "ATK: #{player.attack} DEF: #{player.defence} CON: #{player.constitution}"
    header << " "
    filter_visible(map.grid, player.coords).each do |row|
      map_display << row.join(" ")
    end
    # Pushing additional row prevents truncation in smaller terminal sizes
    map_display << " " * (@h_view_dist * 2)
    screen.draw(map_display, Size.new(0, 0), header)
  end

  # Given a grid, camera co-ordinates and view distances, return 
  # a grid containing only squares within the camera's field of view
  def filter_visible(grid, camera_coords, v_view_dist: @v_view_dist, h_view_dist: @h_view_dist)
    # Filter rows outside view distance
    field_of_view = grid.map do |row|
      row.reject.with_index { |_cell, x_index| (camera_coords[:x] - x_index).abs > h_view_dist }
    end
    # Filter columns outside view distance
    field_of_view.reject!.with_index { |_row, y_index| (camera_coords[:y] - y_index).abs > v_view_dist }
    return field_of_view
  end

  # Displays the combat action selection menu
  def prompt_combat_action
    prompt = TTY::Prompt.new
    answer = prompt.select("What would you like to do?", GameData::COMBAT_MENU_OPTIONS)
    print "\n"
    return answer
  end

  # Displays a series of messages, waiting for keypress
  # input to advance
  def display_messages(msgs)
    prompt = TTY::Prompt.new(quiet: true)
    print "\n"
    msgs.each do |msg|
      puts msg
      print "\n"
      prompt.keypress("Press any key...")
    end
  end

  # Clear the screen (without clearing terminal history)
  def clear
    ANSI::Screen.safe_reset!
  end
end

require "remedy"
require_relative "../modules/utils"
# A menu allowing the player to allocate stat points to their character's stats.
# Custom class created because tty-prompt does not provide menus in this format.
class StatMenu
  include Remedy
  def initialize(starting_stats, starting_points)
    @starting_stats = starting_stats
    @stats = Utils.depth_two_clone(starting_stats)
    @starting_points = starting_points
    @points = starting_points
    @line_no = 0
    @header = Header.new
    @footer = Footer.new
    @stat_index = @stats.keys
    @header << "Please allocate your character's stat points."
    @header << "Use the left and right arrow keys to assign points, and enter to confirm."
  end

  def process_input(key)
    case key
    when :right
      add_point
    # Left arrow key reduces highlighted stat, but not below its starting value
    when :left
      subtract_point
    # Up and down arrow keys to move around list
    when :down, :up
      change_line(key)
    # :control_m represents carriage return
    when :control_m
      return true, @stats if @points.zero?

      @footer << "You must allocate all stat points to continue.".colorize(:red) if @footer.lines.empty?
    end
    return false
  end

  def add_point
    return unless @points.positive?

    @points -= 1
    @stats[@stat_index[@line_no]][:value] += 1
  end

  def subtract_point
    unless @points < @starting_points &&
           @stats[@stat_index[@line_no]][:value] > @starting_stats[@stat_index[@line_no]][:value]
      return
    end

    @points += 1
    @stats[@stat_index[@line_no]][:value] -= 1
  end

  def change_line(key)
    change = key == :down ? 1 : -1
    @line_no = Utils.collar(0, @line_no + change, @stats.length - 1)
  end

  def get_display_parameters
    return [@stats, @points, @line_no, @header, @footer]
  end
end

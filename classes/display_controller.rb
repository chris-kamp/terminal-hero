require "remedy"
require "tty-prompt"
require_relative "../modules/game_data"

# Controls the display of output to the user
class DisplayController
  include Remedy
  include GameData

  def initialize(map, player)
    @map = map
    @player = player
  end

  # Draws one frame of the visible portion of the map
  def draw_map
    screen = Viewport.new
    map_display = Content.new
    filter_visible(@map.grid, @player.coords).each do |row|
      map_display << row.join(" ")
    end
    screen.draw(map_display, Size.new(0, 0))
  end

  # Given a grid, camera co-ordinates and view distances, return 
  # a grid containing only squares within the camera's field of view
  def filter_visible(grid, camera_coords, v_view_dist: GameData::V_VIEW_DIST, h_view_dist: GameData::H_VIEW_DIST)
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
    return prompt.select("What would you like to do?", GameData::COMBAT_MENU_OPTIONS)
  end
end

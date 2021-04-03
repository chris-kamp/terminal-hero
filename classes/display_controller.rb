require "remedy"

# Controls the display of output to the user
class DisplayController
  include Remedy

  def initialize(map, player)
    @map = map
    @player = player
  end

  def draw_map
    screen = Viewport.new
    map_display = Content.new
    @map.grid.each do |row|
      map_display << row.join(" ")
    end
    screen.draw(map_display, Size.new(0, 0))
  end
end

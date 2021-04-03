class Player
  attr_reader :coords

  def initialize(coords = { x: 2, y: 2 })
    @coords = coords
  end
end

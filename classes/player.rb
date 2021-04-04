require_relative "../modules/game_data"
require_relative "../classes/creature"

# Represents the player's character
class Player < Creature
  include GameData

  attr_accessor :coords
  attr_reader :name
  attr_writer :map

  def initialize(name = "Player", coords: GameData::DEFAULT_COORDS, max_hp: GameData::PLAYER_DEFAULT_HP, current_hp: max_hp)
    super(max_hp, current_hp)
    @coords = coords
    @name = name

    # Player is instantiated before Map but requires a reference to it,
    # so @map is assigned manually after initialization
    @map = nil
  end

  # Given a direction to move, return the destination coords
  def move(direction)
    return {
      x: @coords[:x] + GameData::MOVE_KEYS[direction][:x],
      y: @coords[:y] + GameData::MOVE_KEYS[direction][:y]
    }
  end
end

require_relative "../modules/game_data"
require_relative "../classes/creature"

# Represents the player's character
class Player < Creature
  include GameData

  attr_accessor :coords
  attr_reader :name, :current_xp
  attr_writer :map

  def initialize(name: "Player", coords: GameData::DEFAULT_COORDS, stats: GameData::DEFAULT_STATS, health_lost: 0, current_xp: 0)
    super(stats, health_lost)
    @coords = coords
    @name = name
    @current_xp = current_xp

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

  # Given a level, calculate the XP required to level up
  def calc_xp_to_level(current_lvl: @level, constant: GameData::LEVELING_CONSTANT, exponent: GameData::LEVELING_EXPONENT)
    return (constant * (current_lvl**exponent)).round
  end

  # Gain a given amount of XP, and return the amount gained
  def gain_xp(xp)
    @current_xp += xp
    return xp
  end

  # Return a string showing Player's progress to next level
  def xp_progress
    return "#{@current_xp}/#{calc_xp_to_level}"
  end
end

require_relative "../modules/game_data"
require_relative "../classes/creature"

# Represents the player's character
class Player < Creature
  include GameData

  attr_accessor :coords, :stats, :map
  attr_reader :current_xp
  # attr_writer :map

  def initialize(name: "Player", coords: GameData::DEFAULT_COORDS, level: 1, stats: GameData::DEFAULT_STATS, health_lost: 0, current_xp: 0)
    super(name, stats, health_lost, level)
    @coords = coords
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

  # Lose a given amount of XP (but not reducing current XP below 0), and return the amount lost
  def lose_xp(xp)
    @current_xp = [@current_xp - xp, 0].max
    return xp
  end

  # Return a string showing Player's progress to next level
  def xp_progress
    return "#{@current_xp}/#{calc_xp_to_level}"
  end

  # Returns whether the player's current xp is sufficient to level up
  def leveled_up?
    return @current_xp >= calc_xp_to_level
  end

  # Levels up the player based on current XP
  # and returns the number of levels gained
  def level_up
    return 0 unless leveled_up?

    levels_gained = 0
    while @current_xp >= calc_xp_to_level
      @current_xp -= calc_xp_to_level
      @level += 1
      levels_gained += 1
    end
    return levels_gained
  end

  # Update the player's stats to reflect a given statblock,
  # and restore hp to full
  def allocate_stats(stats)
    @stats = stats
    @max_hp = calc_max_hp
    @current_hp = @max_hp
  end

  # Export all values required for initialization to a hash, to be stored in a JSON save file
  def export
    return {
      name: @name,
      coords: @coords,
      level: @level,
      stats: @stats,
      health_lost: (@max_hp - @current_hp),
      current_xp: @current_xp
    }
  end
end

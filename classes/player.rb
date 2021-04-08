require_relative "../modules/game_data"
require_relative "../classes/creature"
require_relative "../classes/tile"

# Represents the player's character
class Player < Creature

  attr_accessor :stats
  attr_reader :current_xp, :tile

  def initialize(name: "Player", coords: GameData::DEFAULT_COORDS, level: 1, stats: GameData::DEFAULT_STATS, health_lost: 0, current_xp: 0, tile: Tile.new(**GameData::MAP_SYMBOLS[:player]), tile_under: nil)
    super(name, coords, stats, health_lost, level, tile, tile_under)
    @current_xp = current_xp
  end

  # Given a level, calculate the XP required to level up
  def calc_xp_to_level(current_lvl: @level, constant: GameData::LEVELING_CONSTANT, exponent: GameData::LEVELING_EXPONENT)
    return (constant * (current_lvl**exponent)).round
  end

  # Apply any healing and XP gain or loss after the end of a combat encounter,
  #  based on the outcome of the combat and the enemy fought. Return xp gained or lost (if any) for display to the user.
  def post_combat(outcome, enemy)
    case outcome
    when :victory
      return gain_xp(enemy.calc_xp)
    when :defeat
      heal_hp(@max_hp)
      return lose_xp((enemy.calc_xp * GameData::XP_LOSS_MULTIPLIER).round)
    else
      return nil
    end
  end

  # Gain a given amount of XP, and return the amount gained
  def gain_xp(xp_gained)
    @current_xp += xp_gained
    return xp_gained
  end

  # Lose a given amount of XP (but not reducing current XP below 0), and return the amount lost
  def lose_xp(xp_lost)
    @current_xp = [@current_xp - xp_lost, 0].max
    return xp_lost
  end

  # Return a string showing Player's progress to next level
  def xp_progress
    return "#{@current_xp}/#{calc_xp_to_level}"
  end

  # Returns whether the player's current xp is sufficient to level up
  def leveled_up?
    return @current_xp >= calc_xp_to_level
  end

  # Levels up the player based on current XP and returns the number of levels gained
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
      current_xp: @current_xp,
      tile_under: @tile_under.export
    }
  end
end

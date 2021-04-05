require_relative "creature"
require_relative "../modules/game_data"
require_relative "../modules/utils"

# Represents an enemy that the player can fight
class Monster < Creature
  def initialize(name: "Monster", stats: GameData::DEFAULT_STATS, health_lost: 0, level_base: 1, level_range: GameData::MONSTER_LEVEL_VARIANCE, level: nil)
    level = set_level(level_base, level_range) if level.nil?
    stats = allocate_stats(stats, level)
    super(name, stats, health_lost, level)
  end

  # Set level, based on base level and maximum deviation from that base
  def set_level(level_base, level_range)
    min = [level_base - level_range, 1].max
    max = level_base + level_range
    return rand(min..max)
  end

  # Calculate stat points based on monster level, and randomly allocate them among stats
  def allocate_stats(starting_stats, level)
    stat_points = (level - 1) * GameData::STAT_POINTS_PER_LEVEL
    stats = Utils.depth_two_clone(starting_stats)
    keys = stats.keys.shuffle
    keys.each do |key|
      point_spend = rand(0..stat_points)
      stats[key][:value] += point_spend
      stat_points -= point_spend
    end
    return stats
  end

  # Calculate the amount of XP a monster is worth, based on its level and 
  # an exponent and range
  def calc_xp(level: @level, exponent: GameController::LEVELING_EXPONENT, constant: level)
    return constant + (level**exponent).round
  end
end

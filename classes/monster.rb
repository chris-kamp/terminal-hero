require_relative "creature"
require_relative "../modules/game_data"

# Represents an enemy that the player can fight
class Monster < Creature
  def initialize(name: "Monster", stats: GameData::DEFAULT_STATS, health_lost: 0, level_base: 1, level_range: GameData::MONSTER_LEVEL_VARIANCE, level: nil)
    level = set_level(level_base, level_range) if level.nil?
    super(name, stats, health_lost, level)
  end

  # Set level, based on base level and maximum deviation from that base
  def set_level(level_base, level_range)
    min = [level_base - level_range, 1].max
    max = level_base + level_range
    return rand(min..max)
  end

  # Calculate the amount of XP a monster is worth, based on its level and 
  # an exponent and range
  def calc_xp(level: @level, exponent: GameController::LEVELING_EXPONENT, constant: level)
    return constant + (level**exponent).round
  end
end

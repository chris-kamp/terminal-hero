require_relative "creature"
require_relative "../modules/game_data"

# Represents an enemy that the player can fight
class Monster < Creature
  # def initialize(stats: GameData::DEFAULT_STATS, health_lost: 0, level: 1)
  def initialize(stats: GameData::DEFAULT_STATS, health_lost: 48, level: 1)
    super(stats, health_lost, level)
  end

  # Calculate the amount of XP a monster is worth, based on its level and 
  # an exponent and range
  def calc_xp(level: @level, exponent: GameController::LEVELING_EXPONENT, constant: level)
    # return constant + (level**exponent).round
    return 8
  end
end

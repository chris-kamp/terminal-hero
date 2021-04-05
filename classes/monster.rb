require_relative "creature"
require_relative "../modules/game_data"

# Represents an enemy that the player can fight
class Monster < Creature
  def initialize(stats: GameData::DEFAULT_STATS, health_lost: 0)
    super(stats, health_lost)
  end
end
require_relative "creature"
require_relative "../modules/game_data"

# Represents an enemy that the player can fight
class Monster < Creature
  def initialize(max_hp: GameData::MONSTER_DEFAULT_HP, current_hp: max_hp)
    super(max_hp, current_hp)
  end
end
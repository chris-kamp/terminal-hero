# Represents a creature that can participate in combat
# (ie. Player and Monsters)
require_relative "../modules/game_data"
class Creature
  include GameData
  attr_reader :max_hp, :current_hp

  def initialize(max_hp = GameData::MONSTER_DEFAULT_HP, current_hp = max_hp)
    @max_hp = max_hp
    @current_hp = current_hp
  end

  def calc_damage_dealt(min, max, roll)
    diff = max - min
    addition = (roll * diff).round
    return min + addition
  end
end

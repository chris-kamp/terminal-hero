# Represents a creature that can participate in combat
# (ie. Player and Monsters)
class Creature
  attr_reader :max_hp, :current_hp

  def initialize(max_hp = 100, current_hp = max_hp)
    @max_hp = max_hp
    @current_hp = current_hp
  end

  def calc_damage_dealt(min, max, roll)
    diff = max - min
    addition = (roll * diff).round
    return min + addition
  end
end

# Provides methods for entities that engage in combat
# (ie. Player and Monsters)
module Fightable
  def calc_damage_dealt(min, max, roll)
    diff = max - min
    addition = (roll * diff).round
    return min + addition
  end

  def roll_random
    srand Time.now.to_i
    return rand
  end
end

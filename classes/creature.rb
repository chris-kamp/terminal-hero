# Represents a creature that can participate in combat
# (ie. Player and Monsters)
class Creature
  def calc_damage_dealt(min, max, roll)
    diff = max - min
    addition = (roll * diff).round
    return min + addition
  end
end
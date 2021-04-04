require_relative "../modules/game_data"
require_relative "../modules/utils"

# Represents a creature that can participate in combat
# (ie. Player and Monsters)
class Creature
  include GameData
  include Utils
  attr_reader :max_hp, :current_hp

  def initialize(max_hp = GameData::MONSTER_DEFAULT_HP, current_hp = max_hp)
    @max_hp = max_hp
    @current_hp = current_hp
  end

  # Calculate damage range based on combat stats, returning {min: min, max: max}
  # Placeholder values until stats implemented
  def calc_damage_range
    return { min: 10, max: 20 }
  end

  # Determine damage within a range based on a random (or given) roll
  def calc_damage_dealt(min: calc_damage_range[:min], max: calc_damage_range[:max], roll: Utils.roll_random)
    diff = max - min
    addition = (roll * diff).round
    return min + addition
  end

  # Reduce hp by damage taken, after applying defence, but not below 0
  def receive_damage(base_damage, defence: 0)
    damage = [base_damage - defence, 1].max
    @current_hp = [@current_hp - damage, 0].max
    return damage
  end

  # Increase hp by healing received, not exceeding max hp
  def heal_hp(healing)
    @current_hp = [@current_hp + healing, @max_hp].min
    return healing
  end

  # Attempt to flee from an enemy in combat
  # Chance is 50/50 as a placeholder until stats implemented
  def flee(_enemy, roll: Utils.roll_random)
    return roll >= 0.5
  end

  # Returns true if the creature is dead (hp at or below zero)
  def dead?
    return @current_hp <= 0
  end
end

require_relative "../modules/game_data"
require_relative "../modules/utils"

# Represents a creature that can participate in combat
# (ie. Player and Monsters)
class Creature
  include GameData
  include Utils
  attr_accessor :coords
  attr_reader :max_hp, :current_hp, :stats, :level, :name, :avatar

  def initialize(name = "Creature", coords = nil, stats = GameData::DEFAULT_STATS, health_lost = 0, level = 1, avatar = "?")
    @name = name
    @level = level
    @stats = Utils.depth_two_clone(stats)
    @max_hp = calc_max_hp
    @current_hp = @max_hp - health_lost
    @coords = coords
    @avatar = avatar
  end

  # Given a direction to move, return the destination coords
  def calc_destination(direction)
    return nil if direction.nil?

    return {
      x: @coords[:x] + GameData::MOVE_KEYS[direction][:x],
      y: @coords[:y] + GameData::MOVE_KEYS[direction][:y]
    }
  end

  # Calculate max HP based on stats (constitution)
  def calc_max_hp
    return @stats[:con][:value] * 10
  end

  # Calculate damage range based on a given attack stat value,
  # returning {min: min, max: max}
  def calc_damage_range(attack: stats[:atk][:value])
    return { min: attack, max: (attack * 1.5).round }
  end

  # Determine damage within a range based on a random (or given) roll
  def calc_damage_dealt(min: calc_damage_range[:min], max: calc_damage_range[:max])
    return rand(min..max)
  end

  # Reduce hp by damage taken, after applying defence stat, but not below 0
  def receive_damage(base_damage, defence: @stats[:dfc][:value])
    reduction = (defence.to_f / 2).round
    damage = [base_damage - reduction, 1].max
    @current_hp = [@current_hp - damage, 0].max
    return damage
  end

  # Increase hp by healing received, not exceeding max hp
  def heal_hp(healing)
    @current_hp = [@current_hp + healing, @max_hp].min
    return healing
  end

  # Attempt to flee from an enemy in combat
  # Chance of success varies with level difference
  def flee(enemy)
    level_difference = @level - enemy.level
    target = Utils.collar(0.05, 0.5 - (level_difference / 10.0), 0.95)
    return rand >= target
  end

  # Returns true if the creature is dead (hp at or below zero)
  def dead?
    return @current_hp <= 0
  end
end

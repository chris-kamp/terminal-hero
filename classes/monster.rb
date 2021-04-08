require_relative "creature"
require_relative "../modules/game_data"
require_relative "../modules/utils"

# Represents an enemy that the player can fight
class Monster < Creature
  attr_reader :event
  def initialize(name: "Monster", coords: nil, stats: GameData::DEFAULT_STATS, health_lost: 0, level_base: 1, level_range: GameData::MONSTER_LEVEL_VARIANCE, level: nil, avatar: "%".colorize(:red), event: :combat)
    level = set_level(level_base, level_range) if level.nil?
    stats = allocate_stats(stats, level)
    super(name, coords, stats, health_lost, level, avatar)
    @event = event
  end

  # Set level, based on base level and maximum deviation from that base
  def set_level(level_base, level_range)
    min = [level_base - level_range, 1].max
    max = level_base + level_range
    return rand(min..max)
  end

  # Calculate stat points based on monster level, and randomly allocate them among stats
  def allocate_stats(starting_stats, level)
    stat_points = (level - 1) * GameData::STAT_POINTS_PER_LEVEL
    stats = Utils.depth_two_clone(starting_stats)
    keys = stats.keys.shuffle
    keys.each do |key|
      point_spend = rand(0..stat_points)
      stats[key][:value] += point_spend
      stat_points -= point_spend
    end
    stats[keys[-1]][:value] += stat_points
    return stats
  end

  # Calculate the amount of XP a monster is worth, based on its level and
  # an exponent and range
  def calc_xp(level: @level, exponent: GameData::LEVELING_EXPONENT, constant: level)
    return constant + (level**exponent).round
  end

  # Decide whether and where to move
  def choose_move(player_coords)
    return nil unless rand < 0.75

    x_difference = @coords[:x] - player_coords[:x]
    y_difference = @coords[:y] - player_coords[:y]
    directions = { x: [:left, :right], y: [:up, :down] }
    if x_difference.abs + y_difference.abs <= 6
      axis = x_difference.abs > y_difference.abs ? :x : :y
      direction = @coords[axis] > player_coords[axis] ? directions[axis][0] : directions[axis][1]
    else
      direction = [:left, :right, :up, :down][rand(0..3)]
    end
    return direction
  end

  # Export all values required for initialization to a hash, to be stored in a JSON save file
  def export
    return {
      name: @name,
      coords: @coords,
      level: @level,
      stats: @stats,
      health_lost: (@max_hp - @current_hp),
      avatar: @avatar,
      event: @event
    }
  end
end

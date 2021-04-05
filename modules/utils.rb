# A module containing general utility methods
module Utils
  # Returns a value "collared" within a given range
  def self.collar(min, val, max)
    return [[min, val].max, max].min
  end

  # Clones a hash, then clones each of its values (but not any deeper values)
  def self.depth_two_clone(hash)
    clone = hash.dup
    clone.each { |key, value| clone[key] = value.dup }
    return clone
  end

end

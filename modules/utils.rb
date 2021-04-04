# A module containing general utility methods
module Utils
  def self.roll_random
    srand Time.now.to_i
    return rand
  end

  def self.collar(min, val, max)
    return [[min, val].max, max].min
  end
end

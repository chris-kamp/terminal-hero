# A module containing general utility methods
module Utils
  def roll_random
    srand Time.now.to_i
    return rand
  end
end
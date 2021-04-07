require_relative "../classes/monster"
require_relative "../modules/game_data"

describe Monster do
  before(:all) do
    @monster = Monster.new
  end

  it "instantiates" do
    expect(@monster).to_not be_nil
  end

  it "inherits from Creature" do
    expect(@monster).to be_kind_of(Creature)
  end

  describe ".calc_xp" do
    it "returns the correct XP amount for a given level" do
      expect(@monster.calc_xp(level: 5, exponent: 2, constant: 5)).to eq(30)
      expect(@monster.calc_xp(level: 10, exponent: 1.5, constant: 0)).to eq(32)
    end
    it "works with default values when no arguments passed" do
      monster2 = Monster.new(level: 1)
      expect(monster2.calc_xp).to eq(1 + (1**GameData::LEVELING_EXPONENT).round)
    end
  end
end

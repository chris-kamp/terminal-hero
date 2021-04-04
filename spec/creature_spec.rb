require_relative "../classes/creature"
require_relative "../modules/game_data"

describe Creature do
  include GameData
  before(:all) do
    @creature = Creature.new
  end

  it "instantiates" do
    expect(@creature).to_not be_nil
  end

  it "instantiates with default hp values" do
    expect(@creature.max_hp).to eq GameData::MONSTER_DEFAULT_HP
    expect(@creature.current_hp).to eq GameData::MONSTER_DEFAULT_HP
  end

  it "instantiates with passed hp values" do
    @creature2 = Creature.new(75, 50)
    expect(@creature2.max_hp).to eq 75
    expect(@creature2.current_hp).to eq 50
  end

  it "instantiates with full hp if only max hp passed in" do
    @creature2 = Creature.new(75)
    expect(@creature2.max_hp).to eq 75
    expect(@creature2.current_hp).to eq 75
  end

  describe ".calc_damage_dealt" do
    it "returns min value for roll of 0" do
      expect(@creature.calc_damage_dealt(5, 10, 0)).to eq 5
      expect(@creature.calc_damage_dealt(0, 5, 0)).to eq 0
    end

    it "returns max value for roll of 1" do
      expect(@creature.calc_damage_dealt(10, 20, 1)).to eq 20
      expect(@creature.calc_damage_dealt(5, 5, 0)).to eq 5
    end

    it "returns correct result for rolls between 0 and 1" do
      expect(@creature.calc_damage_dealt(0, 100, 0.5)).to eq 50
      expect(@creature.calc_damage_dealt(0, 100, 0.38124)).to eq 38
      expect(@creature.calc_damage_dealt(0, 100, 0.38924)).to eq 39
    end
  end
end
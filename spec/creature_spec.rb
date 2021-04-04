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
      expect(@creature.calc_damage_dealt(min: 5, max: 10, roll: 0)).to eq 5
      expect(@creature.calc_damage_dealt(min: 0, max: 5, roll: 0)).to eq 0
    end

    it "returns max value for roll of 1" do
      expect(@creature.calc_damage_dealt(min: 10, max: 20, roll: 1)).to eq 20
      expect(@creature.calc_damage_dealt(min: 5, max: 5, roll: 0)).to eq 5
    end

    it "returns correct result for rolls between 0 and 1" do
      expect(@creature.calc_damage_dealt(min: 0, max: 100, roll: 0.5)).to eq 50
      expect(@creature.calc_damage_dealt(min: 0, max: 100, roll: 0.38124)).to eq 38
      expect(@creature.calc_damage_dealt(min: 0, max: 100, roll: 0.38924)).to eq 39
    end
  end

  describe ".receive_damage" do
    before(:each) do
      @creature = Creature.new(50, 50)
    end

    it "reduces current hp" do
      @creature.receive_damage(10)
      expect(@creature.current_hp).to eq 40
    end

    it "applies defence where less than damage" do
      @creature.receive_damage(10, defence: 5)
      expect(@creature.current_hp).to eq 45
    end

    it "deals 1 damage where defence exceeds base damage" do
      @creature.receive_damage(10, defence: 15)
      expect(@creature.current_hp).to eq 49
    end

    it "doesn't reduce hp below zero" do
      @creature.receive_damage(60)
      expect(@creature.current_hp).to eq 0
    end
  end
end

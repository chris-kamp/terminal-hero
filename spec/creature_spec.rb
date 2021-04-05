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

  it "instantiates with default values" do
    expect(@creature.level).to eq 1
    expect(@creature.stats[:atk][:value]).to eq GameData::DEFAULT_STATS[:atk][:value]
    expect(@creature.stats[:dfc][:value]).to eq GameData::DEFAULT_STATS[:dfc][:value]
    expect(@creature.stats[:con][:value]).to eq GameData::DEFAULT_STATS[:con][:value]
    expect(@creature.max_hp).to eq GameData::DEFAULT_STATS[:con][:value] * 10
    expect(@creature.current_hp).to eq GameData::DEFAULT_STATS[:con][:value] * 10
  end

  it "instantiates with passed values" do
    stats = {
      atk: {
        value: 7, index: 0
      },
      dfc: {
        value: 3, index: 1
      },
      con: {
        value: 12, index: 2
      }
    }

    @creature2 = Creature.new("Creature", stats, 10)
    expect(@creature2.stats[:atk][:value]).to eq stats[:atk][:value]
    expect(@creature2.stats[:dfc][:value]).to eq stats[:dfc][:value]
    expect(@creature2.stats[:con][:value]).to eq stats[:con][:value]
    expect(@creature2.max_hp).to eq stats[:con][:value] * 10
    expect(@creature2.current_hp).to eq stats[:con][:value] * 10 - 10
  end

  describe ".receive_damage" do
    before(:each) do
      @creature = Creature.new
    end

    it "calculates correctly where defence is less than 2x base damage" do
      @creature.receive_damage(10, defence: 6)
      expect(@creature.current_hp).to eq GameData::DEFAULT_STATS[:con][:value] * 10 - 7
    end

    it "deals 1 damage where defence exceeds 2x base damage" do
      @creature.receive_damage(10, defence: 30)
      expect(@creature.current_hp).to eq GameData::DEFAULT_STATS[:con][:value] * 10 - 1
    end

    it "doesn't reduce hp below zero" do
      @creature.receive_damage(9999)
      expect(@creature.current_hp).to eq 0
    end
  end
end

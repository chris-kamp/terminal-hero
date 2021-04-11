require "rspec"
require_relative "../classes/creature"
require_relative "../modules/game_data"

describe Creature do
  include GameData
  before(:all) do
    @default_params = ["Creature", nil, GameData::DEFAULT_STATS, 0, 1, "?"]
    @creature = Creature.new(*@default_params)
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

    @creature2 = Creature.new(*@default_params[0..1], stats, 10, *@default_params[4..5])
    expect(@creature2.stats[:atk][:value]).to eq stats[:atk][:value]
    expect(@creature2.stats[:dfc][:value]).to eq stats[:dfc][:value]
    expect(@creature2.stats[:con][:value]).to eq stats[:con][:value]
    expect(@creature2.max_hp).to eq stats[:con][:value] * 10
    expect(@creature2.current_hp).to eq stats[:con][:value] * 10 - 10
  end

  describe ".calc_destination" do
    before(:each) do
      @creature3 = Creature.new("Creature", { x: 4, y: 4 }, *@default_params[2..-1])
    end

    it "returns the square to the left" do
      expect(@creature3.calc_destination(:left)).to eq({x: 3, y: 4})
    end
    it "returns the square to the right" do
      expect(@creature3.calc_destination(:right)).to eq({x: 5, y: 4})
    end
    it "returns the square above" do
      expect(@creature3.calc_destination(:up)).to eq({x: 4, y: 3})
    end
    it "returns the square below" do
      expect(@creature3.calc_destination(:down)).to eq({x: 4, y: 5})
    end
    it "works from different starting coords" do
      creature4 = Creature.new("Creature", { x: 3, y: 5 }, *@default_params[2..-1])
      expect(creature4.calc_destination(:down)).to eq({ x: 3, y: 6 })
    end
  end

  describe ".calc_max_hp" do
    it "returns the Creature's con stat times the relevant multiplier" do
      expect(@creature.calc_max_hp).to eq GameData::CON_TO_HP * GameData::DEFAULT_STATS[:con][:value]
    end
  end

  describe ".calc_damage_range" do
    it "returns the correct range for a given attack stat value" do
      expect(@creature.calc_damage_range(attack: 10)).to eq({ min: 10, max: 15 })
    end
  end

  describe ".receive_damage" do
    before(:each) do
      @creature = Creature.new(*@default_params)
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

  describe ".heal_hp" do
    before(:each) do
      @creature4 = Creature.new(*@default_params[0..2], 10, 2, "?")
    end

    it "increases current hp by the correct amount" do
      @creature4.heal_hp(3)
      expect(@creature4.current_hp).to eq(@creature4.max_hp - 7)
    end

    it "doesn't increase current hp beyond max hp" do
      @creature4.heal_hp(500)
      expect(@creature4.current_hp).to eq(@creature4.max_hp)
    end
  end
end

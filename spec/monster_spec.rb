require "rspec"
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

  describe ".select_level" do
    it "returns the correct level for a given level_base and roll" do
      allow(@monster).to receive(:rand, &:max)
      expect(@monster.select_level(5)).to eq 5 + GameData::MONSTER_LEVEL_VARIANCE
    end

    it "won't return less than 1" do
      allow(@monster).to receive(:rand, &:min)
      expect(@monster.select_level(-10)).to eq 1
    end
  end

  describe ".allocate_stats" do
    it "generates expected stat values for given rolls" do
      stats = {
        atk: { value: 5 },
        dfc: { value: 5 },
        con: { value: 5 }
      }
      allow(@monster).to receive(:rand, &:max)
      expect(@monster.allocate_stats(stats, 2).values.map { |stat| stat[:value] }.sort).to eq [5, 5, 10]
      allow(@monster).to receive(:rand) { |range| range.to_a[1] }
      expect(@monster.allocate_stats(stats, 2).values.map { |stat| stat[:value] }.sort).to eq [6, 6, 8]
    end
    it "doesn't mutate the starting stats array" do
      stats = {
        atk: { value: 5 },
        dfc: { value: 5 },
        con: { value: 5 }
      }
      @monster.allocate_stats(stats, 2)
      expect(stats.values.map { |stat| stat[:value] }).to eq [5, 5, 5]
    end
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

  describe ".choose_move" do
    it "returns nil for rolls outside the threshold" do
      monster2 = Monster.new(coords: { x: 3, y: 3 })
      allow(monster2).to receive(:rand) { 0.9 }
      expect(monster2.choose_move({ y: 2, x: 2 })).to be nil
    end

    it "moves towards player when player is in range" do
      monster3 = Monster.new(coords: { x: 3, y: 4 })
      allow(monster3).to receive(:rand) { 0.2 }
      expect(monster3.choose_move({ y: 2, x: 2 })).to be :up
      expect(monster3.choose_move({ y: 3, x: 5 })).to be :right
    end

    it "makes the expected random move for a given set of rolls" do
      monster4 = Monster.new(coords: { x: 15, y: 15 })
      allow(monster4).to receive(:rand).and_return(0.1, 3)
      expect(monster4.choose_move({ y: 2, x: 2 })).to be :down
    end
  end
end

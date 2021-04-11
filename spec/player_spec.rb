require "rspec"
require_relative "../lib/terminal_hero/classes/player"
require_relative "../lib/terminal_hero/modules/game_data"

describe Player do
  include GameData
  before(:all) { @player = Player.new(coords: { x: 2, y: 2 }) }

  it "instantiates an object" do
    expect(@player).to_not be_nil
  end

  it "inherits from Creature" do
    expect(@player).to be_kind_of(Creature)
  end

  it "instantiates with default values" do
    expect(@player.current_xp).to eq 0
    expect(@player.coords[:x]).to eq(2)
    expect(@player.coords[:y]).to eq(2)
  end

  it "instantiates with given values" do
    player2 = Player.new(current_xp: 50)
    expect(player2.current_xp).to eq 50
  end

  describe ".calc_xp_to_level" do
    it "calculates required XP correctly" do
      expect(@player.calc_xp_to_level(current_lvl: 5, constant: 10, exponent: 2)).to eq 250
      expect(@player.calc_xp_to_level(current_lvl: 17, constant: 100, exponent: 1.5)).to eq 7009
    end
  end

  describe ".calc_max_hp" do
    it "calculates max HP correctly" do
      player3 = Player.new(stats:
        {
          atk: { value: 5 },
          dfc: { value: 5 },
          con: { value: 7 }
        })
      expect(player3.calc_max_hp).to eq 120
    end
  end

  describe ".post_combat" do
    before(:each) do
      @enemy = double("enemy")
    end
    it "returns the result of gain_xp on :victory" do
      allow(@enemy).to receive(:calc_xp) { 10 }
      allow(@player).to receive(:gain_xp) { |val| val * 2 }
      expect(@player.post_combat(:victory, @enemy)).to eq 20
    end

    it "calls heal_hp and returns lose_xp on :defeat" do
      expect(@player).to receive(:heal_hp).once
      allow(@player).to receive(:lose_xp) { 23 }
      expect(@player.post_combat(:defeat, @enemy)).to eq 23
    end

    it "returns nil for other values" do
      expect(@player.post_combat(:irrelevantvalue, @enemy)).to be nil
    end
  end

  describe ".gain_xp" do
    before(:each) do
      @player2 = Player.new
    end
    it "awards a given amount of XP" do
      @player2.gain_xp(5)
      expect(@player2.current_xp).to eq 5
    end
  end

  describe ".lose_xp" do
    before(:each) do
      @player2 = Player.new
    end
    it "calculates lost xp correctly" do
      @player2.gain_xp(5)
      @player2.lose_xp(level: 2, exponent: 2, constant: 2, modifier: 0.5)
      expect(@player2.current_xp).to eq 1
    end
    it "doesn't reduce XP below 0" do
      @player2.gain_xp(5)
      @player2.lose_xp(constant: 50)
      expect(@player2.current_xp).to eq 0
    end
  end

  describe ".xp_progress" do
    it "returns a string in the form current xp/xp to level" do
      player2 = Player.new(current_xp: 5)
      allow(player2).to receive(:calc_xp_to_level) { 10 }
      expect(player2.xp_progress).to eq "5/10"
    end
  end

  describe ".leveled_up?" do
    it "returns true if current xp equal to or greater than required xp" do
      player2 = Player.new(level: 1, current_xp: 100)
      expect(player2.leveled_up?).to be true
    end
    it "returns false if current xp is less than required xp" do
      player2 = Player.new(level: 1, current_xp: 0)
      expect(player2.leveled_up?).to be false
    end
  end

  # Values used in these tests may require modification if the leveling
  # exponent or constant change
  describe ".level_up" do
    before(:each) do
      @player2 = Player.new(level: 1, current_xp: 0)
    end
    it "increases the player's level where current XP sufficient to level up" do
      @player2.gain_xp(10)
      @player2.level_up
      expect(@player2.level).to eq 2
      expect(@player2.current_xp).to eq 0
    end
    it "handles excess XP correctly" do
      @player2.gain_xp(15)
      @player2.level_up
      expect(@player2.current_xp).to eq 5
    end
    it "handles multiple level increases correctly" do
      @player2.gain_xp(105)
      levels_gained = @player2.level_up
      expect(levels_gained).to eq 3
      expect(@player2.level).to eq 4
      expect(@player2.current_xp).to eq 7
    end
    it "returns the number of levels gained" do
      @player2.gain_xp(40)
      levels_gained = @player2.level_up
      expect(levels_gained).to eq 2
      expect(@player2.level).to eq 3
    end
  end

  describe ".allocate_stats" do
    it "updates player's stats, max hp and current hp" do
      player2 = Player.new
      allow(player2).to receive(:calc_max_hp) { 70 }
      stats = {atk: 13, dfc: 23, con: 7}
      player2.allocate_stats(stats)
      expect(player2.stats).to eq stats
      expect(player2.max_hp).to eq 70
      expect(player2.current_hp).to eq 70
    end
  end
end

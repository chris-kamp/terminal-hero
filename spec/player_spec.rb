require "rspec"
require_relative "../classes/player"
require_relative "../modules/game_data"

describe Player do
  include GameData
  before(:all) { @player = Player.new(coords: { x: 2, y: 2 }) }

  it "instantiates an object" do
    expect(@player).to_not be_nil
  end

  it "inherits from Creature" do
    expect(@player).to be_kind_of(Creature)
  end

  it "instantiates with default XP values" do
    expect(@player.current_xp).to eq 0
  end

  it "instantiates with given XP values" do
    player2 = Player.new(current_xp: 50)
    expect(player2.current_xp).to eq 50
  end

  describe ".coords" do
    it "has default value of 2, 2" do
      expect(@player.coords[:x]).to eq(2)
      expect(@player.coords[:y]).to eq(2)
    end
  end

  describe ".calc_xp_to_level" do
    it "calculates required XP correctly" do
      expect(@player.calc_xp_to_level(current_lvl: 5, constant: 10, exponent: 2)).to eq 250
      expect(@player.calc_xp_to_level(current_lvl: 17, constant: 100, exponent: 1.5)).to eq 7009
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
    it "subtracts a given amount of XP" do
      @player2.gain_xp(5)
      @player2.lose_xp(3)
      expect(@player2.current_xp).to eq 2
    end
    it "doesn't reduce XP below 0" do
      @player2.gain_xp(5)
      @player2.lose_xp(15)
      expect(@player2.current_xp).to eq 0
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
end

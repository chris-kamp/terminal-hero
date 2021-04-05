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

  describe ".move" do
    it "returns the square to the left" do
      expect(@player.move(:left)).to eq({x: 1, y: 2})
    end
    it "returns the square to the right" do
      expect(@player.move(:right)).to eq({x: 3, y: 2})
    end
    it "returns the square above" do
      expect(@player.move(:up)).to eq({x: 2, y: 1})
    end
    it "returns the square below" do
      expect(@player.move(:down)).to eq({x: 2, y: 3})
    end
    it "works from different starting coords" do
      player2 = Player.new(coords: { x: 3, y: 5 })
      expect(player2.move(:down)).to eq({x: 3, y: 6})
    end
  end

  describe ".calc_xp_to_level" do
    it "calculates required XP correctly" do
      expect(@player.calc_xp_to_level(current_lvl: 5, constant: 10, exponent: 2)).to eq 250
      expect(@player.calc_xp_to_level(current_lvl: 17, constant: 100, exponent: 1.5)).to eq 7009
    end
  end

end

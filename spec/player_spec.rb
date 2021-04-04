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

  it "instantiates with default HP values" do
    expect(@player.max_hp).to eq GameData::PLAYER_DEFAULT_HP
    expect(@player.current_hp).to eq GameData::PLAYER_DEFAULT_HP
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
end

require "rspec"
require_relative "../classes/player"

describe Player do
  before(:each) { @player = Player.new }

  it "instantiates an object" do
    expect(@player).to_not be_nil
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
    xit "works from different starting coords" do
    end
  end
end

require "rspec"
require_relative "../classes/map"
require_relative "../classes/player"

describe Map do
  before(:each) do
    @player = Player.new({ x: 2, y: 2 })
    @map = Map.new(@player, 10, 10)
  end

  it "instantiates an object" do
    expect(@map).to_not be_nil
  end
  
  describe ".update_map" do
    it "returns false for out of bounds or malformed player moves" do
      expect(@map.update_map({x: -1, y: 2})).to be false
      expect(@map.update_map({x: 11, y: 2})).to be false
      expect(@map.update_map({x: 2, y: -3})).to be false
      expect(@map.update_map({x: 1, y: 15})).to be false
      expect(@map.update_map({x: -1, y: 15})).to be false
      expect(@map.update_map({x: nil, y: nil})).to be false
      expect(@map.update_map(nil)).to be false
    end

    it "returns false when trying to move to a blocked square" do
      expect(@map.grid[0][0].blocking).to be true
      expect(@map.update_map({x: 0, y: 0})).to be false
    end

    it "updates the map for valid player moves" do
      @map.update_map({ x: 2, y: 1 })
      prev_tile = @map.under_player
      expect(@map.grid[1][2]).to eq @map.symbols[:player]
      expect(@map.grid[2][2]).to eq prev_tile
    end
  end
end

require_relative "../classes/tile"

describe Tile do
  it "instantiates an object" do
    tile = Tile.new
    expect(tile).to_not be_nil
  end
  describe ".blocking" do
    it "returns true when true is passed as a parameter" do
      tile = Tile.new(blocking: true)
      expect(tile.blocking).to be true
    end
    it "returns false when false or no value is passed for blocking" do
      tile = Tile.new(blocking: false)
      tile2 = Tile.new
      expect(tile.blocking).to be false
      expect(tile2.blocking).to be false
    end
  end
end
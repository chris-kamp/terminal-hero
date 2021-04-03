require_relative "../classes/tile"

describe Tile do
  it "instantiates an object" do
    tile = Tile.new("@", :blue)
    expect(tile).to_not be_nil
  end
  describe ".blocking" do
    it "returns true when true is passed as a parameter" do
      tile = Tile.new("|", :default, blocking: true)
      expect(tile.blocking).to be true
    end
    it "returns false when false or no value is passed for blocking" do
      tile = Tile.new("F", :yellow, blocking: false)
      tile2 = Tile.new("T", :green)
      expect(tile.blocking).to be false
      expect(tile2.blocking).to be false
    end
  end
end
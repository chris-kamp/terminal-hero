require_relative "../classes/game_controller"
require_relative "../classes/creature"
require_relative "../classes/tile"

describe GameController do
  before(:all) do
    @game_controller = GameController.new
  end

  it "instantiates an object" do
    expect(@game_controller).to_not be_nil
  end

  describe ".trigger_map_event" do
    it "returns false for tiles without events" do
      tile = Tile.new("?")
      expect(@game_controller.trigger_map_event(tile)).to be false
    end
  end
end

require_relative "../classes/display_controller"

describe DisplayController do
  before(:each) do
    @player = Player.new({ x: 2, y: 2 })
    @map = Map.new(@player, 10, 10)
    @display_controller = DisplayController.new(@map, @player)
  end

  it "instantiates an object" do
    expect(@display_controller).to_not be_nil
  end
end

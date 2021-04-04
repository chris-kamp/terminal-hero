require_relative "../classes/game_controller"
require_relative "../classes/creature"

describe GameController do
  before(:all) do
    @game_controller = GameController.new
  end

  it "instantiates an object" do
    expect(@game_controller).to_not be_nil
  end
end

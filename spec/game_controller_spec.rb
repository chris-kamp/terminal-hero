require_relative "../classes/game_controller"

describe GameController do
  before(:each) do
    @game_controller = GameController.new
  end

  it "instantiates an object" do
    expect(@game_controller).to_not be_nil
  end
end
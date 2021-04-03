require "rspec"
require_relative "../classes/map"
require_relative "../classes/player"

describe Map do
  before(:each) do
    @player = Player.new
    @map = Map.new(@player)
  end

  it "instantiates an object" do
    expect(@map).to_not be_nil
  end
end

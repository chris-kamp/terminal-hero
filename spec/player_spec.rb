require "rspec"
require_relative "../classes/player"

describe Player do
  before(:each) { @player = Player.new }

  it "instantiates an object" do
    expect(@player).to_not be_nil
  end
  it "has default coords of 2, 2" do
    expect(@player.coords[:x]).to eq(2)
    expect(@player.coords[:y]).to eq(2)
  end
end

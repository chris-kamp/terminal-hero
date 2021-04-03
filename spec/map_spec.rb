require "rspec"
require_relative "../classes/map"

describe Map do
  before(:each) { @map = Map.new }

  it "instantiates an object" do
    expect(@map).to_not be_nil
  end

  
end

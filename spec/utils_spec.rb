require "rspec"
require_relative "../modules/utils"

describe Utils do
  include Utils

  it "exists" do
    expect(Utils).to_not be_nil
  end
end
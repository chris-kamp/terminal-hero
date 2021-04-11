require "rspec"
require_relative "../lib/terminal_hero/modules/utils"

describe Utils do
  include Utils

  it "exists" do
    expect(Utils).to_not be_nil
  end

  describe ".collar" do
    it "returns values inside the range" do
      expect(Utils.collar(5, 7, 10)).to eq 7
    end

    it "returns min value for values beneath the range" do
      expect(Utils.collar(4, -3, 10)).to eq 4

    end

    it "returns max value for values above the range" do
      expect(Utils.collar(1, 17, 8)).to eq 8
    end
  end
end
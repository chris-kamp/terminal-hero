require "rspec"
require_relative "../modules/display_controller"

describe DisplayController do
  it "exists" do
    expect(DisplayController).to_not be_nil
  end

  describe ".filter_visible" do
    it "returns a sub-grid based on given view distances" do
      grid = [
        (0..10).to_a,
        (10..20).to_a,
        (20..30).to_a,
        (30..40).to_a,
        (40..50).to_a,
        (50..60).to_a,
        (60..70).to_a,
        (70..80).to_a,
        (80..90).to_a,
        (90..100).to_a
      ]
      expected_view = [
        (33..37).to_a,
        (43..47).to_a,
        (53..57).to_a,
        (63..67).to_a,
        (73..77).to_a
      ]
      expect(DisplayController.filter_visible(grid, { x: 5, y: 5 }, view_dist: [2, 2])).to eq expected_view
    end
  end
  describe ".calculate_padding" do
    before(:each) do
      @header = double("header")
      @content = double("content")
      @size = double("size")
      @lines = ["a", "aaa", "aaaaa"]
      allow(@size).to receive(:rows) { 30 }
      allow(@size).to receive(:cols) { 60 }
      allow(@header).to receive(:lines) { @lines }
      allow(@content).to receive(:lines) { @lines }
    end
    it "returns correct top padding" do
      expect(DisplayController.calculate_padding(@header, @content, @size)).to eq [12, 27]
    end
  end
end

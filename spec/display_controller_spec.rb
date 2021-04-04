require_relative "../classes/display_controller"

describe DisplayController do
  before(:all) do
    @player = Player.new(coords: { x: 2, y: 2 })
    @map = Map.new(@player, width: 10, height: 10)
    @display_controller = DisplayController.new(@map, @player)
  end

  it "instantiates an object" do
    expect(@display_controller).to_not be_nil
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
      expect(@display_controller.filter_visible(grid, { x: 5, y: 5 }, v_view_dist: 2, h_view_dist: 2)).to eq expected_view
    end
  end
end

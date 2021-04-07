require_relative "../classes/display_controller"

describe DisplayController do
  before(:all) do
    @display_controller = DisplayController.new
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
      expect(@display_controller.filter_visible(grid, { x: 5, y: 5 }, view_dist: [2, 2])).to eq expected_view
    end
  end

  describe ".character_name_valid?" do
    it "returns true for valid character names" do
      expect(@display_controller.character_name_valid?("Steve")).to be true
    end
    it "returns false for names containing non-alphanumeric characters" do
      expect(@display_controller.character_name_valid?("St#ve")).to be false
      expect(@display_controller.character_name_valid?("&:Steve")).to be false
    end
    it "returns false for names containing whitespace" do
      expect(@display_controller.character_name_valid?(" Steve")).to be false
      expect(@display_controller.character_name_valid?("Steve ")).to be false
      expect(@display_controller.character_name_valid?("St ve")).to be false
      expect(@display_controller.character_name_valid?("S   teve")).to be false
      expect(@display_controller.character_name_valid?("Steve\n\n")).to be false
    end
    it "returns false for names that are too short" do
      expect(@display_controller.character_name_valid?("")).to be false
      expect(@display_controller.character_name_valid?("St")).to be false
    end
    it "returns false for names that are too long" do
      expect(@display_controller.character_name_valid?("SteveSteveSteveSteve")).to be false
    end
  end
end

require_relative "../modules/game_controller"
require_relative "../classes/creature"
require_relative "../classes/tile"

describe GameController do
  it "exists" do
    expect(GameController).to_not be_nil
  end

  describe ".init_player_and_map" do
    it "returns a player and map with default paramaters" do
      expect(GameController.init_player_and_map[:player]).to be_a Player
      expect(GameController.init_player_and_map[:map]).to be_a Map
    end
    it "returns a player and map with passed paramaters" do
      # Pass arbitrary value to check it is passed through to constructor
      data = GameController.init_player_and_map(player_data: { level: 50, name: "__pname" })
      expect(data[:player].level).to eq 50
    end
  end
end

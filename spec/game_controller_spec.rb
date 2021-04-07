require_relative "../modules/game_controller"
require_relative "../classes/creature"
require_relative "../classes/tile"

describe GameController do
  it "exists" do
    expect(GameController).to_not be_nil
  end

  describe ".start_game" do
    it "returns the result of processing command line args, where not false" do
      allow(InputHandler).to receive(:process_command_line_args) { :state }
      expect(GameController.start_game([])).to be :state
    end
    it "returns the result of a valid user prompt response" do
      allow(DisplayController).to receive(:prompt_title_menu).and_return(GameData::GAME_STATES.keys[0])
      expect(GameController.start_game([])).to be GameData::GAME_STATES.keys[0]
    end
    it "displays an error message from the rescue block if user prompt response is invalid" do
      allow(InputHandler).to receive(:process_command_line_args) { false }
      allow(DisplayController).to receive(:prompt_title_menu).and_return(nil, GameData::GAME_STATES.keys[0])
      allow(DisplayController).to receive(:display_messages)
      expect(DisplayController).to receive(:display_messages)
      GameController.start_game([])
    end
  end

  describe ".tutorial" do
    before(:each) do
      allow(DisplayController).to receive(:display_messages)
      allow(DisplayController).to receive(:prompt_tutorial) { false }
    end
    it "calls the tutorial prompt" do
      expect(DisplayController).to receive(:prompt_tutorial)
      GameController.tutorial
    end
    it "displays the tutorial messages" do
      allow(DisplayController).to receive(:prompt_tutorial).and_return(true, false)
      expect(DisplayController).to receive(:display_messages)
      GameController.tutorial
    end
    it "returns :character_creation" do
      expect(DisplayController).to receive(:prompt_tutorial)
      GameController.tutorial
    end
    it "replays the tutorial if user responds yes to prompt" do
      allow(DisplayController).to receive(:prompt_tutorial).and_return(true, false)
      expect(DisplayController).to receive(:prompt_tutorial).twice
      GameController.tutorial
    end
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

  describe ".character_creation" do
    before(:each) do
      allow(DisplayController).to receive(:prompt_character_name) { "my_name" }
      allow(DisplayController).to receive(:prompt_stat_allocation) { GameData::DEFAULT_STATS }
    end

    it "calls methods to prompt the user to choose name and stats" do
      expect(DisplayController).to receive(:prompt_character_name).once
      expect(DisplayController).to receive(:prompt_stat_allocation).once
      GameController.character_creation
    end
    
    it "returns an array in the form [:world_map, [Map, Player]]" do
      expect(GameController.character_creation[0]).to be(:world_map)
      expect(GameController.character_creation[1][0]).to be_a(Map)
      expect(GameController.character_creation[1][1]).to be_a(Player)
    end

    it "instantiates Player with name and stats received from the prompt methods" do
      expect(GameController.character_creation[1][1].name).to eq "my_name"
    end
  end
end

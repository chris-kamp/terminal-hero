require "rspec"
require_relative "../lib/terminal_hero/modules/game_controller"
require_relative "../lib/terminal_hero/classes/creature"
require_relative "../lib/terminal_hero/classes/tile"

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

  describe ".map_loop" do
    before(:each) do
      allow(GameController).to receive(:save_game)
      allow(DisplayController).to receive(:set_resize_hook)
      allow(DisplayController).to receive(:draw_map)
      allow(Remedy::Interaction).to receive(:new)
      @input_listener = double("input_listener")
      allow(Remedy::Interaction).to receive(:new) { @input_listener }
      @key = double("pressed_key")
      allow(@key).to receive(:name) { "left" } # assumes :left is included in GameData::MOVE_KEYS
      allow(@input_listener).to receive(:loop).and_yield(@key)
      @player = double("player")
      allow(@player).to receive(:name)
      allow(@player).to receive(:calc_destination)
      allow(@player).to receive(:coords)
      @map = double("map")
      @tile = double("tile")
      allow(@tile).to receive(:event) { "event" }
      allow(@map).to receive(:process_movement) { @tile }
      allow(@map).to receive(:move_monsters)
    end

    it "calls the correct methods" do
      expect(GameController).to receive(:save_game)
      expect(DisplayController).to receive(:set_resize_hook).once
      expect(DisplayController).to receive(:draw_map).exactly(3).times
      expect(@map).to receive(:process_movement).once
      expect(@player).to receive(:calc_destination).once
      GameController.map_loop(@map, @player)
    end
    it "returns an array in the form [event, [player, map, tile]] when tile has an event" do
      expect(GameController.map_loop(@map, @player)).to eq ["event", [@player, @map, @tile]]
    end
    it "does not return when tile has no event" do
      allow(@tile).to receive(:event) { nil }
      expect(GameController.map_loop(@map, @player)).to be nil
    end
    it "calls prompt quit when a quit key is pressed" do
      allow(@key).to receive(:name) { "q" }
      allow(GameController).to receive(:prompt_quit)
      expect(GameController).to receive(:prompt_quit)
      GameController.map_loop(@map, @player)
    end
  end
end

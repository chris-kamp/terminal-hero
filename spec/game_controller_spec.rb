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

  describe ".map_loop" do
    before(:each) do
      allow(GameController).to receive(:save_game)
      allow(DisplayController).to receive(:set_resize_hook)
      allow(DisplayController).to receive(:draw_map)
      allow(Remedy::Interaction).to receive(:new)
      @input_listener = double("input_listener")
      allow(Remedy::Interaction).to receive(:new) { @input_listener }
      @key = double("pressed_key")
      allow(@key).to receive(:name) { "left" } # assumes :left is included in GameData::calc_destination_KEYS
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
  end

  describe ".combat_loop" do
    before(:each) do
      allow(DisplayController).to receive(:clear)
      allow(DisplayController).to receive(:display_messages)
      allow(GameController).to receive(:player_act)
      @enemy = double("enemy")
      allow(@enemy).to receive(:dead?)
      allow(@enemy).to receive(:current_hp)
      allow(@enemy).to receive(:max_hp)
      allow(GameController).to receive(:fled_combat?)
      allow(GameController).to receive(:enemy_act)
      @player = double("player")
      allow(@player).to receive(:dead?) { true }
      allow(@player).to receive(:current_hp)
      allow(@player).to receive(:max_hp)
      @map = double("map")
      @tile = double("tile")
      allow(@tile).to receive(:entity)
      allow(GameData::MESSAGES[:enter_combat]).to receive(:call)
    end

    xit "calls the correct methods" do
      expect(DisplayController).to receive(:clear).once
      expect(DisplayController).to receive(:display_messages).once
      expect(GameController).to receive(:player_act).once
      expect(@enemy).to receive(:dead?).once
      expect(GameController).to receive(:fled_combat?).once
      expect(GameController).to receive(:enemy_act).once
      expect(@player).to receive(:dead?).once
      GameController.combat_loop(@player, @map, @tile, @enemy)
    end

    xit "returns an array with victory outcome if enemy dead" do
      allow(@enemy).to receive(:dead?) { true }
      expect(GameController.combat_loop(@player, @map, @tile, @enemy)).to eq [:post_combat, [@player, @enemy, @map, :victory]]
    end

    xit "returns an array with escaped outcome if player fled" do
      allow(GameController).to receive(:fled_combat?) { true }
      expect(GameController.combat_loop(@player, @map, @tile, @enemy)).to eq [:post_combat, [@player, @enemy, @map, :escaped]]
    end

    xit "returns an array with defeat outcome if player dead" do
      expect(GameController.combat_loop(@player, @map, @tile, @enemy)).to eq [:post_combat, [@player, @enemy, @map, :defeat]]
    end

    xit "repeats the loop if all checks are falsey" do
      allow(@player).to receive(:dead?).and_return(false, true)
      expect(@player).to receive(:dead?).twice
      GameController.combat_loop(@player, @map, @tile, @enemy)
    end
  end
end

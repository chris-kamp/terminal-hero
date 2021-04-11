require "rspec"
require_relative "../lib/terminal_hero/modules/input_handler"

describe InputHandler do
  describe ".process_command_line_args" do
    it "returns false when passed a non-array value" do
      expect(InputHandler.process_command_line_args({})).to be false
    end
    it "returns false when passed an empty array" do
      expect(InputHandler.process_command_line_args([])).to be false
    end
    it "returns false when passed an array with an irrelevant first value" do
      expect(InputHandler.process_command_line_args(["__irrelevant_val"])).to be false
    end
    it "returns :new_game when passed an array with a relevant first value" do
      expect(InputHandler.process_command_line_args(["newgame"], new_game_args: ["newgame"])).to be :new_game
    end
    it "returns :load_game when passed an array with a relevant first value" do
      expect(InputHandler.process_command_line_args(["loadgame"], load_game_args: ["loadgame"])).to be :load_game
    end
  end

  describe ".character_name_valid?" do
    it "returns true for valid character names" do
      expect(InputHandler.character_name_valid?("Steve")).to be true
    end
    it "returns false for names containing non-alphanumeric characters" do
      expect(InputHandler.character_name_valid?("St#ve")).to be false
      expect(InputHandler.character_name_valid?("&:Steve")).to be false
    end
    it "returns false for names containing whitespace" do
      expect(InputHandler.character_name_valid?(" Steve")).to be false
      expect(InputHandler.character_name_valid?("Steve ")).to be false
      expect(InputHandler.character_name_valid?("St ve")).to be false
      expect(InputHandler.character_name_valid?("S   teve")).to be false
      expect(InputHandler.character_name_valid?("Steve\n\n")).to be false
    end
    it "returns false for names that are too short" do
      expect(InputHandler.character_name_valid?("")).to be false
      expect(InputHandler.character_name_valid?("St")).to be false
    end
    it "returns false for names that are too long" do
      expect(InputHandler.character_name_valid?("SteveSteveSteveSteve")).to be false
    end
  end
end

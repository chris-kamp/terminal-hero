require_relative "../modules/input_handler"

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
end

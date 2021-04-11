require "rspec"
require_relative "../lib/terminal_hero/classes/map"
require_relative "../lib/terminal_hero/classes/player"
require_relative "../lib/terminal_hero/modules/game_data"
require_relative "../lib/terminal_hero/classes/tile"

describe Map do
  include GameData

  before(:each) do
    @player = Player.new(coords: { x: 2, y: 2 })
    @map = Map.new(player: @player, width: 10, height: 10)
  end

  it "instantiates an object" do
    expect(@map).to_not be_nil
  end

  describe ".process_movement" do
    before(:each) do
      # Prevent errors being rescued and logged during tests
      allow(GameData::MESSAGES[:general_error]).to receive(:call)
      allow(Utils).to receive(:log_error)
      allow(DisplayController).to receive(:display_messages)
    end
    it "raises error and does not update the map for out of bounds or malformed player moves" do
      starting_grid = @map.grid.dup
      expect(@map.process_movement(@player, {x: -1, y: 2})).to raise InvalidInputError
      expect(@map.grid).to eq starting_grid
      expect(@map.process_movement(@player, {x: 11, y: 2})).to raise InvalidInputerror
      expect(@map.grid).to eq starting_grid
      expect(@map.process_movement(@player, {x: 2, y: -3})).to raise InvalidInputerror
      expect(@map.grid).to eq starting_grid
      expect(@map.process_movement(@player, {x: 1, y: 15})).to raise InvalidInputerror
      expect(@map.grid).to eq starting_grid
      expect(@map.process_movement(@player, {x: -1, y: 15})).to raise InvalidInputerror
      expect(@map.grid).to eq starting_grid
      expect(@map.process_movement(@player, {x: nil, y: nil})).to raise InvalidInputerror
      expect(@map.grid).to eq starting_grid
    end

    it "does not update the map when trying to move to a blocked square" do
      expect(@map.grid[0][0].blocking).to be true
      starting_grid = @map.grid.dup
      @map.process_movement(@player, {x: 0, y: 0})
      expect(@map.grid).to eq starting_grid
    end

    it "updates the map for valid player moves" do
      @map.grid[1][2].entity = nil
      @map.process_movement(@player, { x: 2, y: 1 })
      expect(@map.grid[1][2].to_s).to eq @player.avatar
      expect(@map.grid[2][2].to_s).to eq @map.grid[2][2].symbol
    end

    it "returns the destination tile" do
      barrier = GameData::MAP_TILES[:edge]
      expect(@map.process_movement(@player, { x: 1, y: 0 }).symbol).to eq barrier[:symbol].colorize(barrier[:color])
    end

    it "returns nil for invalid destinations" do
      expect(@map.process_movement(@player, { x: -10, y: -10 })).to be_nil
      expect(@map.process_movement(@player, { x: nil, y: 0 })).to be_nil
      expect(@map.process_movement(@player, nil)).to be_nil
    end
  end
end

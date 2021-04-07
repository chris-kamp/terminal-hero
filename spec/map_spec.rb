require "rspec"
require_relative "../classes/map"
require_relative "../classes/player"
require_relative "../modules/game_data"
require_relative "../classes/tile"

describe Map do
  include GameData

  before(:all) do
    @player = Player.new(coords: { x: 2, y: 2 })
    @map = Map.new(player: @player, width: 10, height: 10)
  end

  it "instantiates an object" do
    expect(@map).to_not be_nil
  end

  describe ".process_movement" do
    it "does not update the map for out of bounds or malformed player moves" do
      starting_grid = @map.grid.dup
      @map.process_movement(@player, {x: -1, y: 2})
      expect(@map.grid).to eq starting_grid
      @map.process_movement(@player, {x: 11, y: 2})
      expect(@map.grid).to eq starting_grid
      @map.process_movement(@player, {x: 2, y: -3})
      expect(@map.grid).to eq starting_grid
      @map.process_movement(@player, {x: 1, y: 15})
      expect(@map.grid).to eq starting_grid
      @map.process_movement(@player, {x: -1, y: 15})
      expect(@map.grid).to eq starting_grid
      @map.process_movement(@player, {x: nil, y: nil})
      expect(@map.grid).to eq starting_grid
    end

    it "does not update the map when trying to move to a blocked square" do
      expect(@map.grid[0][0].blocking).to be true
      starting_grid = @map.grid.dup
      @map.process_movement(@player, {x: 0, y: 0})
      expect(@map.grid).to eq starting_grid
    end

    it "updates the map for valid player moves" do
      prev_tile = @player.tile_under
      @map.process_movement(@player, { x: 2, y: 1 })
      expect(@map.grid[1][2].symbol).to eq @map.symbols[:player][:symbol]
      expect(@map.grid[2][2].symbol).to eq prev_tile.symbol
    end

    it "returns the destination tile" do
      barrier = GameData::MAP_SYMBOLS[:edge]
      expect(@map.process_movement(@player, { x: 1, y: 0 }).symbol).to eq barrier[:symbol]
    end

    it "returns nil for invalid destinations" do
      expect(@map.process_movement(@player, { x: -10, y: -10 })).to be_nil
      expect(@map.process_movement(@player, { x: nil, y: 0 })).to be_nil
      expect(@map.process_movement(@player, nil)).to be_nil
    end
  end
end

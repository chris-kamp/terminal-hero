require_relative "../modules/fightable"

class Fighter
  include Fightable
end

describe Fightable do
  before(:all) do
    include Fightable
    @fighter = Fighter.new
  end

  it "exists" do
    expect(Fightable).not_to be_nil
  end

  describe ".calc_damage_dealt" do
    it "returns min value for roll of 0" do
      expect(@fighter.calc_damage_dealt(5, 10, 0)).to eq 5
      expect(@fighter.calc_damage_dealt(0, 5, 0)).to eq 0
    end

    it "returns max value for roll of 1" do
      expect(@fighter.calc_damage_dealt(10, 20, 1)).to eq 20
      expect(@fighter.calc_damage_dealt(5, 5, 0)).to eq 5
    end

    it "returns correct result for rolls between 0 and 1" do
      expect(@fighter.calc_damage_dealt(0, 100, 0.5)).to eq 50
      expect(@fighter.calc_damage_dealt(0, 100, 0.38124)).to eq 38
      expect(@fighter.calc_damage_dealt(0, 100, 0.38924)).to eq 39
    end
  end
end
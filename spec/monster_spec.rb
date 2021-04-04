require_relative "../classes/monster"

describe Monster do
  before(:all) do
    @monster = Monster.new
  end

  it "instantiates" do
    expect(@monster).to_not be_nil
  end

  it "inherits from Creature" do
    expect(@monster).to be_kind_of(Creature)
  end

  it "instantiates with default hp values" do
    expect(@monster.max_hp).to eq GameData::MONSTER_DEFAULT_HP
    expect(@monster.current_hp).to eq GameData::MONSTER_DEFAULT_HP
  end
end

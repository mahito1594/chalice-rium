require "test_helper"

class LayerTest < ActiveSupport::TestCase
  def setup
    @dungeon = dungeons("9kv8xiyi") # has layers of level 1 to 3
  end

  test "should be valid with level in 1..4" do
    @dungeon.layers.delete_all

    (1..4).each do |level|
      assert Layer.new(dungeon: @dungeon, level: level).valid?, "level: #{level}"
    end
  end

  test "should be invalid with level out of 1..4" do
    [ 0, 5 ].each do |level|
      assert_not Layer.new(dungeon: @dungeon, level: level).valid?, "level: #{level}"
    end
  end

  test "should be invalid without level" do
    assert_not Layer.new(dungeon: @dungeon, level: nil).valid?
  end

  test "should be invalid without dungeon" do
    assert_not Layer.new(level: 4).valid?
  end

  test "should be invalid with duplicate level in the same dungeon" do
    layer = Layer.new(dungeon: @dungeon, level: 1)
    assert_not layer.valid?
    assert layer.errors[:level].any?
  end

  test "should allow the same level in another dungeon" do
    other = dungeons("2r8ghidm")
    layers(:"2r8ghidm_1st").destroy!

    assert Layer.new(dungeon: other, level: 1).valid?
  end

  test "should allow blank boss_name" do
    assert Layer.new(dungeon: @dungeon, level: 4, boss_name: nil).valid?
  end
end

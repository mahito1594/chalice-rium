require "test_helper"

class DungeonTest < ActiveSupport::TestCase
  def setup
    @user = users(:willem)
    @dungeon = @user.dungeons.build(glyph: "abcdefgh",
                                    depth: 5,
                                    area: "pthumeru",
                                    is_open: true,
                                    comment: "Test comment")
  end

  test "should be valid with valid attributes" do
    assert @dungeon.valid?
  end

  test "should ensure required layers on initialization" do
    @dungeon.save
    assert_equal 3, @dungeon.layers.size
  end

  test "should remove empty fourth layer before save" do
    @dungeon.layers.build(level: 4, boss_name: "")
    @dungeon.save
    assert_nil @dungeon.layers.find_by(level: 4)
  end

  test "should not allow sinister rite with other rites" do
    fetid_rite = rites(:fetid)
    sinister_rite = rites(:sinister)

    @dungeon.rites << fetid_rite
    @dungeon.rites << sinister_rite

    assert_not @dungeon.valid?
    assert @dungeon.errors[:rites].any?
  end

  test "should allow multiple non-sinister rites" do
    fetid_rite = rites(:fetid)
    rotted_rite = rites(:rotted)

    @dungeon.rites << fetid_rite
    @dungeon.rites << rotted_rite

    assert @dungeon.valid?
  end

  test "should validate loran depth" do
    @dungeon.area = :loran

    @dungeon.depth = 3
    assert_not @dungeon.valid?

    @dungeon.depth = 4
    assert @dungeon.valid?

    @dungeon.depth = 5
    assert @dungeon.valid?
  end

  test "should validate isz depth" do
    @dungeon.area = :isz

    @dungeon.depth = 4
    assert_not @dungeon.valid?

    @dungeon.depth = 5
    assert @dungeon.valid?
  end

  test "should validate hintertomb depth" do
    @dungeon.area = :hintertomb

    @dungeon.depth = 1
    assert_not @dungeon.valid?

    @dungeon.depth = 2
    assert @dungeon.valid?

    @dungeon.depth = 3
    assert @dungeon.valid?

    @dungeon.depth = 4
    assert_not @dungeon.valid?
  end

  # Filter scope tests
  test "with_area scope filters dungeons by area" do
    pthumeru_dungeon = dungeons("9kv8xiyi")
    result = Dungeon.with_area("pthumeru")

    assert_includes result, pthumeru_dungeon
  end

  test "with_area scope returns all when blank" do
    result = Dungeon.with_area("")

    assert_equal Dungeon.all.to_a, result.to_a
  end

  test "with_depth scope filters dungeons by depth" do
    depth_5_dungeon = dungeons("9kv8xiyi")
    result = Dungeon.with_depth(5)

    assert_includes result, depth_5_dungeon
  end

  test "with_depth scope returns all when blank" do
    result = Dungeon.with_depth(nil)

    assert_equal Dungeon.all.to_a, result.to_a
  end

  test "with_all_rites scope returns dungeons with all selected rites (AND logic)" do
    # Create a dungeon with multiple rites
    @dungeon.save!
    @dungeon.rites << rites(:fetid)
    @dungeon.rites << rites(:rotted)

    # Search for dungeons with both fetid AND rotted
    result = Dungeon.with_all_rites([ rites(:fetid).id, rites(:rotted).id ])
    assert_includes result, @dungeon

    # Search for dungeons with fetid, rotted, AND cursed - should NOT include our dungeon
    result = Dungeon.with_all_rites([ rites(:fetid).id, rites(:rotted).id, rites(:cursed).id ])
    assert_not_includes result, @dungeon
  end

  test "with_all_rites scope returns all when blank" do
    result = Dungeon.with_all_rites([])

    assert_equal Dungeon.all.to_a, result.to_a
  end

  test "with_all_rites scope handles empty strings in array" do
    result = Dungeon.with_all_rites([ "", "" ])

    assert_equal Dungeon.all.to_a, result.to_a
  end
end

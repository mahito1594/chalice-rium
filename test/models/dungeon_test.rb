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

  # ==> glyph

  test "should be invalid without a glyph" do
    @dungeon.glyph = nil
    assert_not @dungeon.valid?
  end

  test "should require glyph to be exactly 8 characters" do
    @dungeon.glyph = "abcdefg"
    assert_not @dungeon.valid?

    @dungeon.glyph = "abcdefghi"
    assert_not @dungeon.valid?
  end

  test "should allow only lowercase alphanumerics in glyph" do
    @dungeon.glyph = "abcd-fgh"
    assert_not @dungeon.valid?

    @dungeon.glyph = "1234abcd"
    assert @dungeon.valid?
  end

  test "should reject uppercase glyph because format is validated before downcasing" do
    # before_save :downcase_glyph runs after validation, so uppercase input never reaches it
    @dungeon.glyph = "ABCDEFGH"
    assert_not @dungeon.valid?
    assert @dungeon.errors[:glyph].any?
  end

  test "should be invalid with a duplicate glyph" do
    @dungeon.glyph = dungeons("9kv8xiyi").glyph
    assert_not @dungeon.valid?
    assert @dungeon.errors[:glyph].any?
  end

  # ==> depth

  test "should be invalid without a depth" do
    @dungeon.depth = nil
    assert_not @dungeon.valid?
  end

  test "should be invalid with depth out of 1..5" do
    @dungeon.depth = 0
    assert_not @dungeon.valid?

    @dungeon.depth = 6
    assert_not @dungeon.valid?
  end

  # ==> area x depth combination (decision table)

  VALID_DEPTHS_BY_AREA = {
    "pthumeru" => [ 1, 2, 3, 4, 5 ],
    "loran" => [ 4, 5 ],
    "isz" => [ 5 ],
    "hintertomb" => [ 2, 3 ]
  }.freeze

  VALID_DEPTHS_BY_AREA.each do |area, valid_depths|
    (1..5).each do |depth|
      expected = valid_depths.include?(depth)

      test "area #{area} with depth #{depth} should be #{expected ? 'valid' : 'invalid'}" do
        @dungeon.area = area
        @dungeon.depth = depth

        assert_equal expected, @dungeon.valid?, @dungeon.errors.full_messages.inspect
        assert_equal !expected, @dungeon.errors[:depth].any?
      end
    end
  end

  test "should be invalid without an area" do
    @dungeon.area = nil
    assert_not @dungeon.valid?
  end

  # ==> comment

  test "should allow comment up to 255 characters" do
    @dungeon.comment = "a" * 255
    assert @dungeon.valid?

    @dungeon.comment = "a" * 256
    assert_not @dungeon.valid?
  end

  test "should allow blank comment" do
    @dungeon.comment = nil
    assert @dungeon.valid?
  end

  # ==> layers

  test "should build layers 1 to 3 on initialization" do
    assert_equal [ 1, 2, 3 ], @dungeon.layers.map(&:level)
  end

  test "should not duplicate layers given on initialization" do
    dungeon = Dungeon.new(layers_attributes: [ { level: 1, boss_name: "Watchdog of the Old Lords" } ])

    assert_equal [ 1, 2, 3 ], dungeon.layers.map(&:level)
    assert_equal "Watchdog of the Old Lords", dungeon.layers.first.boss_name
  end

  test "should not build layers for persisted dungeon" do
    dungeon = Dungeon.find(dungeons("9kv8xiyi").id)
    assert_equal 3, dungeon.layers.size
  end

  test "should be invalid with more than 4 layers" do
    @dungeon.layers.build(level: 4, boss_name: "Ebrietas")
    @dungeon.layers.build(level: 4, boss_name: "Ebrietas")
    assert_not @dungeon.valid?
    assert @dungeon.errors[:layers].any?
  end

  test "should remove fourth layer with blank boss_name before save" do
    [ nil, "", "  " ].each_with_index do |boss_name, i|
      dungeon = @user.dungeons.build(glyph: "blank00#{i}", depth: 5, area: "pthumeru")
      dungeon.layers.build(level: 4, boss_name: boss_name)
      dungeon.save!

      assert_equal [ 1, 2, 3 ], dungeon.reload.layers.map(&:level), "boss_name: #{boss_name.inspect}"
    end
  end

  test "should keep fourth layer with boss_name" do
    @dungeon.layers.build(level: 4, boss_name: "Ebrietas")
    @dungeon.save!
    assert_equal "Ebrietas", @dungeon.layers.find_by(level: 4).boss_name
  end

  test "should keep layers 1 to 3 even if boss_name is blank" do
    @dungeon.save!
    assert_equal [ 1, 2, 3 ], @dungeon.reload.layers.map(&:level)
    assert @dungeon.layers.all? { |layer| layer.boss_name.nil? }
  end

  test "layers should be ordered by level" do
    dungeon = dungeons("9kv8xiyi")
    dungeon.layers.create!(level: 4, boss_name: "Ebrietas")
    # recreate level 1 so that its id becomes the largest
    layers(:"9kv8xiyi_1st").destroy!
    dungeon.layers.create!(level: 1, boss_name: "Watchdog of the Old Lords")

    assert_equal [ 1, 2, 3, 4 ], dungeon.reload.layers.map(&:level)
  end

  # ==> rites combination (decision table)

  test "should be valid without rites" do
    assert @dungeon.valid?
  end

  test "should be valid with a single non-sinister rite" do
    @dungeon.rites << rites(:fetid)
    assert @dungeon.valid?
  end

  test "should be valid with sinister rite alone" do
    @dungeon.rites << rites(:sinister)
    assert @dungeon.valid?
  end

  test "should be valid with all non-sinister rites" do
    @dungeon.rites << rites(:fetid) << rites(:rotted) << rites(:cursed)
    assert @dungeon.valid?
  end

  test "should not allow sinister rite with other rites" do
    @dungeon.rites << rites(:fetid) << rites(:sinister)

    assert_not @dungeon.valid?
    assert @dungeon.errors[:rites].any?
  end

  # ==> callbacks / instance methods

  test "prepare_for_form should build the fourth layer and set rite_ids" do
    dungeon = dungeons("9kv8xiyi").prepare_for_form

    assert_equal [ 1, 2, 3, 4 ], dungeon.layers.map(&:level)
    assert_equal [ rites(:fetid), rites(:rotted), rites(:cursed) ].map(&:id).sort, dungeon.rite_ids.sort
  end

  test "prepare_for_form should not duplicate an existing fourth layer" do
    dungeon = dungeons("9kv8xiyi")
    dungeon.layers.create!(level: 4, boss_name: "Ebrietas")

    assert_equal [ 1, 2, 3, 4 ], dungeon.reload.prepare_for_form.layers.map(&:level)
  end

  test "translated_area should return localized area name" do
    expected = { "pthumeru" => "トゥメル", "loran" => "ローラン", "isz" => "イズ", "hintertomb" => "僻墓" }
    expected.each do |area, name|
      @dungeon.area = area
      assert_equal name, @dungeon.translated_area
    end
  end

  test "destroying a dungeon should destroy its layers and dungeon_rites but keep rites" do
    dungeon = dungeons("9kv8xiyi")

    assert_difference -> { Layer.count } => -3, -> { DungeonRite.count } => -3, -> { Rite.count } => 0 do
      dungeon.destroy
    end
  end

  # ==> Filter scopes

  test "with_area scope filters dungeons by area" do
    result = Dungeon.with_area("pthumeru")

    assert_includes result, dungeons("9kv8xiyi")
    assert_not_includes result, dungeons("2r8ghidm")
  end

  test "with_area scope returns all when blank" do
    assert_equal Dungeon.all.to_a, Dungeon.with_area("").to_a
    assert_equal Dungeon.all.to_a, Dungeon.with_area(nil).to_a
  end

  test "with_area scope returns nothing for unknown area" do
    assert_empty Dungeon.with_area("unknown")
  end

  test "with_depth scope filters dungeons by depth" do
    result = Dungeon.with_depth(5)

    assert_includes result, dungeons("9kv8xiyi")
    assert_not_includes result, dungeons("2r8ghidm")
  end

  test "with_depth scope accepts string depth from params" do
    assert_equal [ dungeons("2r8ghidm") ], Dungeon.with_depth("3").to_a
  end

  test "with_depth scope returns all when blank" do
    assert_equal Dungeon.all.to_a, Dungeon.with_depth(nil).to_a
    assert_equal Dungeon.all.to_a, Dungeon.with_depth("").to_a
  end

  test "with_all_rites scope returns dungeons with all selected rites (AND logic)" do
    full = dungeons("9kv8xiyi") # fetid, rotted, cursed
    sinister = dungeons("2r8ghidm") # sinister

    assert_equal [ full ], Dungeon.with_all_rites([ rites(:fetid).id ]).to_a
    assert_equal [ full ], Dungeon.with_all_rites([ rites(:fetid).id, rites(:rotted).id, rites(:cursed).id ]).to_a
    assert_equal [ sinister ], Dungeon.with_all_rites([ rites(:sinister).id ]).to_a
    assert_empty Dungeon.with_all_rites([ rites(:fetid).id, rites(:sinister).id ]).to_a
  end

  test "with_all_rites scope does not match dungeon with only some of the selected rites" do
    @dungeon.rites << rites(:fetid) << rites(:rotted)
    @dungeon.save!

    assert_includes Dungeon.with_all_rites([ rites(:fetid).id, rites(:rotted).id ]), @dungeon
    assert_not_includes Dungeon.with_all_rites([ rites(:fetid).id, rites(:rotted).id, rites(:cursed).id ]), @dungeon
  end

  test "with_all_rites scope accepts string ids and ignores blank values" do
    assert_equal [ dungeons("9kv8xiyi") ], Dungeon.with_all_rites([ "", rites(:fetid).id.to_s ]).to_a
  end

  test "with_all_rites scope returns all when blank" do
    assert_equal Dungeon.all.to_a, Dungeon.with_all_rites([]).to_a
    assert_equal Dungeon.all.to_a, Dungeon.with_all_rites(nil).to_a
    assert_equal Dungeon.all.to_a, Dungeon.with_all_rites([ "", "" ]).to_a
  end

  test "filter scopes can be chained" do
    assert_equal [ dungeons("9kv8xiyi") ],
                 Dungeon.with_area("pthumeru").with_depth(5).with_all_rites([ rites(:cursed).id ]).to_a
    assert_empty Dungeon.with_area("pthumeru").with_depth(3).to_a
  end
end

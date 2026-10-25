# test/controllers/dungeons_controller_test.rb
require "test_helper"

class DungeonsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def setup
    @user = users(:willem)
    @other_user = users(:laurence)
    @dungeon = dungeons("9kv8xiyi") # owned by @user
  end

  # ==> index

  test "should get index without sign in" do
    get root_path
    assert_response :success
    assert_select "a[href=?]", dungeon_path(@dungeon), text: @dungeon.glyph
    assert_select "a[href=?]", dungeon_path(dungeons("2r8ghidm"))
  end

  test "should filter index by area" do
    get root_path, params: { filter: { area: "hintertomb" } }
    assert_response :success
    assert_select "a[href=?]", dungeon_path(dungeons("2r8ghidm"))
    assert_select "a[href=?]", dungeon_path(@dungeon), count: 0
  end

  test "should filter index by depth" do
    get root_path, params: { filter: { depth: "5" } }
    assert_response :success
    assert_select "a[href=?]", dungeon_path(@dungeon)
    assert_select "a[href=?]", dungeon_path(dungeons("2r8ghidm")), count: 0
  end

  test "should filter index by rites" do
    # the filter form sends an empty string as a hidden value
    get root_path, params: { filter: { rite_ids: [ "", rites(:sinister).id.to_s ] } }
    assert_response :success
    assert_select "a[href=?]", dungeon_path(dungeons("2r8ghidm"))
    assert_select "a[href=?]", dungeon_path(@dungeon), count: 0
  end

  test "should combine index filters with AND" do
    get root_path, params: { filter: { area: "pthumeru", depth: "3" } }
    assert_response :success
    assert_select "a[href=?]", dungeon_path(@dungeon), count: 0
    assert_select "a[href=?]", dungeon_path(dungeons("2r8ghidm")), count: 0
  end

  test "should list all dungeons when filter values are blank" do
    get root_path, params: { filter: { area: "", depth: "", rite_ids: [ "" ] } }
    assert_response :success
    assert_select "a[href=?]", dungeon_path(@dungeon)
    assert_select "a[href=?]", dungeon_path(dungeons("2r8ghidm"))
  end

  test "should paginate index by 25 in descending order of created_at" do
    25.times do |i|
      @user.dungeons.create!(glyph: format("page%04d", i), depth: 1, area: "pthumeru",
                             created_at: 1.day.from_now + i.minutes)
    end

    get root_path
    assert_select "a[href=?]", dungeon_path(Dungeon.find_by!(glyph: "page0024"))
    assert_select "a[href=?]", dungeon_path(@dungeon), count: 0

    get root_path, params: { page: 2 }
    assert_select "a[href=?]", dungeon_path(@dungeon)
    assert_select "a[href=?]", dungeon_path(Dungeon.find_by!(glyph: "page0024")), count: 0
  end

  # ==> show

  test "should get show without sign in" do
    get dungeon_path(@dungeon)
    assert_response :success
    assert_select "h3", text: @dungeon.glyph
    assert_match "Bloodletting Beast", response.body
    assert_select "a[href=?]", edit_dungeon_path(@dungeon), count: 0
  end

  test "should show edit and delete buttons only to the owner" do
    sign_in @other_user
    get dungeon_path(@dungeon)
    assert_select "a[href=?]", edit_dungeon_path(@dungeon), count: 0
    assert_select "a[href=?][data-turbo-method=delete]", dungeon_path(@dungeon), count: 0

    sign_in @user
    get dungeon_path(@dungeon)
    assert_select "a[href=?]", edit_dungeon_path(@dungeon)
    assert_select "a[href=?][data-turbo-method=delete]", dungeon_path(@dungeon)
  end

  test "should return not found for nonexistent dungeon" do
    get dungeon_path(id: 0)
    assert_response :not_found
  end

  # ==> new

  test "should redirect new to sign in when not signed in" do
    get new_dungeon_path
    assert_redirected_to new_user_session_path
  end

  test "should get new with four layer fields when signed in" do
    sign_in @user
    get new_dungeon_path
    assert_response :success
    assert_select "input[name^='dungeon[layers_attributes]'][name$='[boss_name]']", count: 4
    assert_select "input[type=checkbox][name='dungeon[rite_ids][]']", count: Rite.count
  end

  # ==> create

  test "should redirect create to sign in when not signed in" do
    assert_no_difference "Dungeon.count" do
      post dungeons_path, params: { dungeon: { glyph: "newglyph", depth: 3, area: "pthumeru" } }
    end
    assert_redirected_to new_user_session_path
  end

  test "should create dungeon with layers and rites" do
    sign_in @user

    assert_difference "Dungeon.count", 1 do
      post dungeons_path, params: { dungeon: { glyph: "newglyph",
                                               depth: 3,
                                               area: "pthumeru",
                                               is_open: "1",
                                               comment: "Test comment",
                                               rite_ids: [ "", rites(:fetid).id.to_s, rites(:rotted).id.to_s ],
                                               layers_attributes: {
                                                 "0" => { level: 1, boss_name: "Watchdog of the Old Lords" },
                                                 "1" => { level: 2, boss_name: "" },
                                                 "2" => { level: 3, boss_name: "Amygdala" },
                                                 "3" => { level: 4, boss_name: "" }
                                               } } }
    end

    dungeon = Dungeon.find_by!(glyph: "newglyph")
    assert_redirected_to dungeon_path(dungeon)
    assert_equal "聖杯ダンジョンが登録されました。", flash[:notice]
    assert_equal @user, dungeon.user
    assert dungeon.is_open
    assert_equal %w[fetid rotted], dungeon.rites.map(&:name).sort
    # empty 4th layer is removed
    assert_equal [ [ 1, "Watchdog of the Old Lords" ], [ 2, "" ], [ 3, "Amygdala" ] ],
                 dungeon.layers.map { |layer| [ layer.level, layer.boss_name ] }
  end

  test "should create dungeon with fourth layer when boss_name is given" do
    sign_in @user

    post dungeons_path, params: { dungeon: { glyph: "fourthly", depth: 5, area: "pthumeru",
                                             layers_attributes: {
                                               "0" => { level: 1 }, "1" => { level: 2 },
                                               "2" => { level: 3 }, "3" => { level: 4, boss_name: "Ebrietas" }
                                             } } }

    assert_equal [ 1, 2, 3, 4 ], Dungeon.find_by!(glyph: "fourthly").layers.map(&:level)
  end

  test "should create dungeon owned by current user regardless of user_id param" do
    sign_in @user

    post dungeons_path, params: { dungeon: { glyph: "newglyph", depth: 3, area: "pthumeru",
                                             user_id: @other_user.id } }

    assert_equal @user, Dungeon.find_by!(glyph: "newglyph").user
  end

  test "should create dungeon without rites when rite_ids is absent" do
    sign_in @user

    post dungeons_path, params: { dungeon: { glyph: "newglyph", depth: 3, area: "pthumeru" } }

    assert_empty Dungeon.find_by!(glyph: "newglyph").rites
  end

  test "should not create dungeon with invalid params" do
    sign_in @user

    assert_no_difference "Dungeon.count" do
      post dungeons_path, params: { dungeon: { glyph: nil } }
    end
    assert_response :unprocessable_content
  end

  test "should not create dungeon with sinister and other rites" do
    sign_in @user

    assert_no_difference "Dungeon.count" do
      post dungeons_path, params: { dungeon: { glyph: "newglyph", depth: 3, area: "pthumeru",
                                               rite_ids: [ rites(:sinister).id, rites(:fetid).id ] } }
    end
    assert_response :unprocessable_content
  end

  test "should not create dungeon with invalid area and depth combination" do
    sign_in @user

    assert_no_difference "Dungeon.count" do
      post dungeons_path, params: { dungeon: { glyph: "newglyph", depth: 1, area: "isz" } }
    end
    assert_response :unprocessable_content
  end

  # ==> edit

  test "should redirect edit to sign in when not signed in" do
    get edit_dungeon_path(@dungeon)
    assert_redirected_to new_user_session_path
  end

  test "should return not found on edit by other user" do
    sign_in @other_user
    get edit_dungeon_path(@dungeon)
    assert_response :not_found
  end

  test "should get edit by owner" do
    sign_in @user
    get edit_dungeon_path(@dungeon)
    assert_response :success
    assert_select "input[name^='dungeon[layers_attributes]'][name$='[boss_name]']", count: 4
  end

  # ==> update

  test "should redirect update to sign in when not signed in" do
    patch dungeon_path(@dungeon), params: { dungeon: { comment: "rewrite" } }
    assert_redirected_to new_user_session_path
    assert_nil @dungeon.reload.comment
  end

  test "should return not found on update by other user" do
    sign_in @other_user
    patch dungeon_path(@dungeon), params: { dungeon: { comment: "rewrite" } }
    assert_response :not_found
    assert_nil @dungeon.reload.comment
  end

  test "should update comment by owner" do
    sign_in @user
    patch dungeon_path(@dungeon), params: { dungeon: { comment: "rewrite" } }
    assert_redirected_to dungeon_path(@dungeon)
    assert_equal "聖杯ダンジョンが更新されました。", flash[:notice]
    assert_equal "rewrite", @dungeon.reload.comment
  end

  test "should not update glyph, area, depth, is_open and rites" do
    sign_in @user

    patch dungeon_path(@dungeon), params: { dungeon: { glyph: "changed0",
                                                       area: "loran",
                                                       depth: 4,
                                                       is_open: "0",
                                                       rite_ids: [ rites(:sinister).id ],
                                                       comment: "rewrite" } }

    assert_redirected_to dungeon_path(@dungeon)
    @dungeon.reload
    assert_equal "9kv8xiyi", @dungeon.glyph
    assert_equal "pthumeru", @dungeon.area
    assert_equal 5, @dungeon.depth
    assert @dungeon.is_open
    assert_equal %w[cursed fetid rotted], @dungeon.rites.map(&:name).sort
  end

  test "should update boss names of layers" do
    sign_in @user
    first = layers(:"9kv8xiyi_1st")

    patch dungeon_path(@dungeon), params: { dungeon: { layers_attributes: {
      "0" => { id: first.id, level: 1, boss_name: "Keeper of the Old Lords" }
    } } }

    assert_equal "Keeper of the Old Lords", first.reload.boss_name
    assert_equal 3, @dungeon.layers.count
  end

  test "should add and remove fourth layer on update" do
    sign_in @user

    patch dungeon_path(@dungeon), params: { dungeon: { layers_attributes: {
      "3" => { level: 4, boss_name: "Ebrietas" }
    } } }
    fourth = @dungeon.layers.find_by!(level: 4)
    assert_equal "Ebrietas", fourth.boss_name

    patch dungeon_path(@dungeon), params: { dungeon: { layers_attributes: {
      "3" => { id: fourth.id, level: 4, boss_name: "" }
    } } }
    assert_not Layer.exists?(fourth.id)
  end

  test "should not update dungeon with invalid params" do
    sign_in @user
    # glyph is not permitted in update_dungeon_params, so it won't cause validation error
    # Test with comment that exceeds 255 characters
    patch dungeon_path(@dungeon), params: { dungeon: { comment: "x" * 256 } }
    assert_response :unprocessable_content
    assert_nil @dungeon.reload.comment
  end

  # ==> destroy

  test "should redirect destroy to sign in when not signed in" do
    assert_no_difference "Dungeon.count" do
      delete dungeon_path(@dungeon)
    end
    assert_redirected_to new_user_session_path
  end

  test "should return not found on destroy by other user" do
    sign_in @other_user
    assert_no_difference "Dungeon.count" do
      delete dungeon_path(@dungeon)
    end
    assert_response :not_found
  end

  test "should destroy dungeon with its layers by owner" do
    sign_in @user
    assert_difference -> { Dungeon.count } => -1, -> { Layer.count } => -3 do
      delete dungeon_path(@dungeon)
    end
    assert_redirected_to root_path
    assert_equal "聖杯ダンジョンが削除されました。", flash[:notice]
  end
end

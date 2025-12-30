# test/controllers/dungeons_controller_test.rb
require "test_helper"

class DungeonsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def setup
    @user = users(:willem)
    @other_user = users(:laurence)
    @dungeon = dungeons("9kv8xiyi")
  end

  test "should get show without sign in" do
    get dungeon_path(@dungeon)
    assert_response :success
  end

  test "should get new if sign in" do
    get new_dungeon_url, as: :html
    assert_redirected_to new_user_session_path

    sign_in @user
    get new_dungeon_url
    assert_response :success
  end

  test "should create dungeon with valid params" do
    post dungeons_url, params: { dungeon: { glyph: "newglyph" } }
    assert_redirected_to new_user_session_path

    sign_in @user
    assert_difference "Dungeon.count", 1 do
      post dungeons_url, params: { dungeon: { glyph: "newglyph",
                                              depth: 3,
                                              area: "pthumeru",
                                              comment: "Test comment",
                                              user_id: @user.id } }
    end
    assert_redirected_to dungeon_url(Dungeon.last)
  end

  test "should get edit if sign in to correct user" do
    get edit_dungeon_path(@dungeon), as: :html
    assert_redirected_to new_user_session_path

    sign_in @other_user
    get edit_dungeon_path(@dungeon)
    assert_response :not_found

    sign_out @other_user
    sign_in @user
    get edit_dungeon_path(@dungeon)
    assert_response :success
  end

  test "should not create dungeon with invalid params" do
    sign_in @user
    post dungeons_url, params: { dungeon: { glyph: nil } }
    assert_response :unprocessable_content
  end

  test "should update dungeon with valid params" do
    # redirect when not signed in
    patch dungeon_path(@dungeon), params: { dungeon: { comment: "rewrite" } }
    assert_redirected_to new_user_session_path

    # error when signed in but not owner
    sign_in @other_user
    patch dungeon_path(@dungeon), params: { dungeon: { comment: "rewrite" } }
    assert_response :not_found

    sign_out @other_user
    sign_in @user
    patch dungeon_path(@dungeon), params: { dungeon: { comment: "rewrite" } }
    assert_redirected_to @dungeon
    @dungeon.reload
    assert_equal "rewrite", @dungeon.comment
  end

  test "should not update dungeon with invalid params" do
    sign_in @user
    patch dungeon_path(@dungeon), params: { dungeon: { glyph: nil } }
    assert_redirected_to @dungeon
  end

  test "should destroy dungeon" do
    delete dungeon_path(@dungeon)
    assert_redirected_to new_user_session_path

    sign_in @other_user
    delete dungeon_path(@dungeon)
    assert_response :not_found

    sign_out @other_user
    sign_in @user
    assert_difference("Dungeon.count", -1) do
      delete dungeon_url(@dungeon)
    end
    assert_redirected_to root_path
  end

  # Filter tests
  test "should get index with filter params" do
    get root_path, params: { filter: { area: "pthumeru", depth: 5 } }
    assert_response :success
  end

  test "should get index with rite filter" do
    get root_path, params: { filter: { rite_ids: [ rites(:fetid).id.to_s ] } }
    assert_response :success
  end

  test "should get index without filter params" do
    get root_path
    assert_response :success
  end
end

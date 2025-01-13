require "test_helper"

class RegisterNewDungeonTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def setup
    @user = users(:willem)
    @other_user =  users(:laurence)
  end

  test "redirects to login when accessing new dungeon page without login" do
    get root_path
    assert_response :success
    assert_select "a[href=?]", new_dungeon_path, count: 1

    get new_dungeon_path
    assert_redirected_to new_user_session_path
  end

  test "creates a new dungeon after login" do
    sign_in @user
    get new_dungeon_path
    assert_response :success

    assert_difference("Dungeon.count", 1) do
      post dungeons_path, params: { dungeon: { glyph: "abcdefgh",
                                               depth: 1,
                                               area: "pthumeru",
                                               is_open: true,
                                               comment: "A new dungeon",
                                               user_id: @user.id } }
    end
    assert_redirected_to dungeon_path(Dungeon.last)
  end
end

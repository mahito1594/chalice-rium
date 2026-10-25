require "test_helper"

class RegisterNewDungeonTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def setup
    @user = users(:willem)
  end

  test "guest sees no register link and is redirected to login" do
    get root_path
    assert_response :success
    assert_select "a[href=?]", new_dungeon_path, count: 0

    get new_dungeon_path
    assert_redirected_to new_user_session_path
  end

  test "user can register, update and delete a dungeon" do
    sign_in @user

    # register
    get new_dungeon_path
    assert_response :success
    post dungeons_path, params: { dungeon: { glyph: "abcdefgh",
                                             depth: 4,
                                             area: "loran",
                                             is_open: "1",
                                             comment: "A new dungeon",
                                             rite_ids: [ "", rites(:cursed).id.to_s ],
                                             layers_attributes: {
                                               "0" => { level: 1, boss_name: "Loran Silverbeast" },
                                               "1" => { level: 2, boss_name: "" },
                                               "2" => { level: 3, boss_name: "Darkbeast" },
                                               "3" => { level: 4, boss_name: "" }
                                             } } }
    dungeon = Dungeon.find_by!(glyph: "abcdefgh")
    assert_redirected_to dungeon_path(dungeon)

    follow_redirect!
    assert_select "h3", text: "abcdefgh"
    assert_match "ローラン", response.body
    assert_match "呪い", response.body
    assert_match "Loran Silverbeast", response.body
    assert_match "A new dungeon", response.body

    # the new dungeon appears on the user's profile
    get user_path(@user)
    assert_select "a[href=?]", dungeon_path(dungeon)

    # update
    get edit_dungeon_path(dungeon)
    assert_response :success
    patch dungeon_path(dungeon), params: { dungeon: { comment: "Updated" } }
    follow_redirect!
    assert_match "Updated", response.body

    # delete
    delete dungeon_path(dungeon)
    assert_redirected_to root_path
    follow_redirect!
    assert_select "a[href=?]", dungeon_path(dungeon), count: 0
  end
end

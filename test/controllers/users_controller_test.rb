require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def setup
    @user = users(:willem)
    @other_user = users(:laurence)
  end

  # ==> show

  test "should get show with own dungeons only" do
    @user.update!(bio: "Fear the Old Blood")

    get user_path(@user)
    assert_response :success
    assert_select "h3", text: @user.display_name
    assert_match "Fear the Old Blood", response.body
    assert_select "a[href=?]", dungeon_path(dungeons("9kv8xiyi"))
    assert_select "a[href=?]", dungeon_path(dungeons("2r8ghidm")), count: 0
  end

  test "should return not found for nonexistent user" do
    get user_path(username: "@nobody")
    assert_response :not_found
  end

  test "should show edit and register buttons only on own profile" do
    sign_in @user
    get user_path(@user)
    assert_select "a[href=?]", edit_user_path(@user)
    assert_select "a[href=?]", new_dungeon_path

    get user_path(@other_user)
    assert_select "a[href=?]", edit_user_path(@other_user), count: 0
    assert_select "a[href=?]", new_dungeon_path, count: 0
  end

  # ==> edit

  test "should redirect edit to sign in when not signed in" do
    get edit_user_path(@user)
    assert_redirected_to new_user_session_path
  end

  test "should redirect edit to root by other user" do
    sign_in @other_user
    get edit_user_path(@user)
    assert_redirected_to root_path
    assert_response :see_other
  end

  test "should get edit by correct user" do
    sign_in @user
    get edit_user_path(@user)
    assert_response :success
  end

  # ==> update

  test "should redirect update to sign in when not signed in" do
    patch user_path(@user), params: { user: { display_name: "Provost Willem" } }
    assert_redirected_to new_user_session_path
    assert_equal "Master Willem", @user.reload.display_name
  end

  test "should not update profile by incorrect user" do
    sign_in @other_user
    patch user_path(@user), params: { user: { display_name: "Provost Willem" } }
    assert_redirected_to root_path
    assert_equal "Master Willem", @user.reload.display_name
  end

  test "should update profile with valid information" do
    sign_in @user

    patch user_path(@user), params: { user: { display_name: "Provost Willem",
                                              bio: "  Fear the Old Blood  ",
                                              twitter_link: "willem" } }
    assert_redirected_to user_path(@user)
    assert_equal "プロフィールが更新されました。", flash[:notice]
    @user.reload
    assert_equal "Provost Willem", @user.display_name
    assert_equal "Fear the Old Blood", @user.bio
    assert_equal "willem", @user.twitter_link
  end

  test "should not update profile with invalid information" do
    sign_in @user

    patch user_path(@user), params: { user: { display_name: nil } }
    assert_response :unprocessable_content
    assert_equal "Master Willem", @user.reload.display_name

    patch user_path(@user), params: { user: { twitter_link: "https://x.com/willem" } }
    assert_response :unprocessable_content
    assert_nil @user.reload.twitter_link
  end

  test "should not update username and email via profile update" do
    sign_in @user

    patch user_path(@user), params: { user: { username: "@changed", email: "changed@example.com",
                                              display_name: "Provost Willem" } }
    assert_redirected_to user_path(@user)
    @user.reload
    assert_equal "@willem", @user.username
    assert_equal "willem@example.com", @user.email
  end

  # ==> destroy

  test "should redirect destroy to sign in when not signed in" do
    assert_no_difference "User.count" do
      delete user_path(@user)
    end
    assert_redirected_to new_user_session_path
  end

  test "should not destroy other user" do
    sign_in @other_user
    assert_no_difference "User.count" do
      delete user_path(@user)
    end
    assert_redirected_to root_path
  end

  test "should destroy user self with own dungeons" do
    sign_in @user
    assert_difference -> { User.count } => -1, -> { Dungeon.count } => -1 do
      delete user_path(@user)
    end
    assert_redirected_to root_path
    assert_response :see_other
    assert_equal "アカウントが削除されました。", flash[:notice]
  end
end

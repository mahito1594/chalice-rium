require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def setup
    @user = users(:willem)
    @other_user = users(:laurence)
  end

  test "should get show" do
    get user_path(@user)
    assert_response :success
  end

  test "should get edit when sign in to correct user" do
    get edit_user_path(@user)
    assert_redirected_to new_user_session_path

    sign_in @other_user
    get edit_user_path(@user)
    assert_redirected_to root_path

    sign_in @user
    get edit_user_path(@user)
    assert_response :success
  end

  test "should update profile with valid information" do
    sign_in @user

    patch user_path(@user), params: { user: { display_name: nil } }
    assert_response :unprocessable_content

    patch user_path(@user), params: { user: { display_name: "Provost Willem" } }
    assert_redirected_to user_path(@user)
    assert_not flash.empty?
    @user.reload
    assert_equal "Provost Willem", @user.display_name
  end

  test "should not update profile by incorrect user" do
    sign_in @other_user
    patch user_path(@user), params: { user: { display_name: "Provost Willem" } }
    assert_redirected_to root_path
  end

  test "should destroy user self" do
    delete user_path(@user)
    assert_redirected_to new_user_session_path

    sign_in @other_user
    assert_no_difference "User.count" do
      delete user_path(@user)
    end
    assert_redirected_to root_path

    sign_in @user
    assert_difference "User.count", -1 do
      delete user_path(@user)
    end
    assert_redirected_to root_path
  end

  test "should show new button to register dungeon if his/her own profile" do
    sign_in @user
    get user_path(@user)
    assert_select "a[href=?]", new_dungeon_path

    get user_path(@other_user)
    assert_select "a[href=?]", new_dungeon_path, count: 0
  end
end

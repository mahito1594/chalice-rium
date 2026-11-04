require "test_helper"

class LoginTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:willem)
  end

  test "login with valid information" do
    post user_session_path, params: { user: { username: @user.username, password: "password" } }
    assert_redirected_to root_path

    follow_redirect!
    assert_select "a[href=?]", user_path(@user)
  end

  # username is listed in case_insensitive_keys / strip_whitespace_keys in config/initializers/devise.rb,
  # so Devise normalizes it before lookup (issue #425).
  test "login with username in different case succeeds" do
    post user_session_path, params: { user: { username: "@WILLEM", password: "password" } }
    assert_redirected_to root_path
  end

  test "login with username with surrounding whitespace succeeds" do
    post user_session_path, params: { user: { username: " @willem ", password: "password" } }
    assert_redirected_to root_path
  end

  test "login with wrong password" do
    post user_session_path, params: { user: { username: @user.username, password: "wrongpassword" } }
    assert_response :unprocessable_content
  end

  test "login with nonexistent username" do
    post user_session_path, params: { user: { username: "@nobody", password: "password" } }
    assert_response :unprocessable_content
  end

  test "login with email instead of username is not supported" do
    post user_session_path, params: { user: { username: @user.email, password: "password" } }
    assert_response :unprocessable_content
  end

  test "unconfirmed user cannot login" do
    @user.update_columns(confirmed_at: nil)

    post user_session_path, params: { user: { username: @user.username, password: "password" } }
    assert_redirected_to new_user_session_path
    follow_redirect!
    assert_select "a[href=?]", user_path(@user), count: 0
  end

  test "logout" do
    post user_session_path, params: { user: { username: @user.username, password: "password" } }

    delete destroy_user_session_path
    assert_redirected_to root_path

    get edit_user_path(@user)
    assert_redirected_to new_user_session_path
  end
end

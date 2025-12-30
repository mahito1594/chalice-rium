require "test_helper"

class LogIn < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def setup
    @user = users(:willem)
  end
end

class LoginTest < LogIn
  test "login with valid information" do
    post user_session_path, params: { user: { username: @user.username, password: "password" } }
    assert_response :redirect
    assert_redirected_to root_path
  end

  test "login with invalid information" do
    post user_session_path, params: { user: { username: @user.username, password: "wrongpassword" } }
    assert_response :unprocessable_content
  end
end

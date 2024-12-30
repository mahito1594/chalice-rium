require "test_helper"

class SignUpTest < ActionDispatch::IntegrationTest
  test "user can sign up with valid information" do
    get new_user_registration_path
    assert_response :success

    assert_difference "User.count", 1 do
      post user_registration_path, params: { user: { username: "@test",
                                                     display_name: "Test User",
                                                     email: "test@example.com",
                                                     password: "password",
                                                     password_confirmation: "password" } }
    end

    follow_redirect!
    assert_response :success
  end

  test "user cannot sign up with invalid information" do
    get new_user_registration_path
    assert_response :success

    assert_no_difference "User.count" do
      post user_registration_path, params: { user: { username: "invalid",
                                                     display_name: "Invalid User",
                                                     email: "invalid",
                                                     password: "short",
                                                     password_confirmation: "short" } }
    end

    assert_response :unprocessable_entity
  end
end

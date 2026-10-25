require "test_helper"

class SignUpTest < ActionDispatch::IntegrationTest
  def setup
    ActionMailer::Base.deliveries.clear
  end

  test "user can sign up, confirm email and login" do
    get new_user_registration_path
    assert_response :success

    assert_difference "User.count", 1 do
      post user_registration_path, params: { user: { username: "@Test_User",
                                                     display_name: "Test User",
                                                     email: "test@example.com",
                                                     password: "password",
                                                     password_confirmation: "password" } }
    end

    user = User.find_by!(email: "test@example.com")
    assert_equal "@test_user", user.username
    assert_not user.confirmed?

    assert_equal 1, ActionMailer::Base.deliveries.size
    mail = ActionMailer::Base.deliveries.last
    assert_equal [ "test@example.com" ], mail.to
    follow_redirect!
    assert_response :success

    # cannot login before confirmation
    post user_session_path, params: { user: { username: "@test_user", password: "password" } }
    assert_redirected_to new_user_session_path

    token = mail.body.encoded[/confirmation_token=([^"&\s]+)/, 1]
    get user_confirmation_path(confirmation_token: token)
    assert user.reload.confirmed?

    post user_session_path, params: { user: { username: "@test_user", password: "password" } }
    assert_redirected_to root_path
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

    assert_equal 0, ActionMailer::Base.deliveries.size
    assert_response :unprocessable_content
  end

  test "user cannot sign up with username already taken in different case" do
    assert_no_difference "User.count" do
      post user_registration_path, params: { user: { username: "@WILLEM",
                                                     display_name: "Fake Willem",
                                                     email: "fake@example.com",
                                                     password: "password",
                                                     password_confirmation: "password" } }
    end

    assert_response :unprocessable_content
  end

  test "user cannot sign up with mismatched password confirmation" do
    assert_no_difference "User.count" do
      post user_registration_path, params: { user: { username: "@test",
                                                     display_name: "Test User",
                                                     email: "test@example.com",
                                                     password: "password",
                                                     password_confirmation: "different" } }
    end

    assert_response :unprocessable_content
  end
end

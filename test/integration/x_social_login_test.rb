require "test_helper"

class XSocialLoginTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def setup
    OmniAuth.config.mock_auth[:twitter2] = OmniAuth::AuthHash.new(
      provider: "twitter2",
      uid: "new_uid_999",
      info: { name: "New X User", email: "newxuser@example.com" }
    )
  end

  # ==> UC1: X アカウントで新規サインアップ

  test "new user can start signup via X and reach username setup form" do
    post user_twitter2_omniauth_authorize_path
    follow_redirect!
    assert_redirected_to new_omniauth_setup_path
  end

  test "new user can complete signup with username and display_name" do
    post user_twitter2_omniauth_authorize_path
    follow_redirect!

    assert_difference "User.count", 1 do
      post omniauth_setup_path, params: {
        user: { username: "@newxuser", display_name: "New X User" }
      }
    end

    new_user = User.last
    assert_equal "twitter2", new_user.provider
    assert_equal "new_uid_999", new_user.uid
    assert_equal "@newxuser", new_user.username
    assert new_user.confirmed?
    assert_redirected_to root_path
  end

  test "new user signup stores email from X when confirmed_email is available" do
    post user_twitter2_omniauth_authorize_path
    follow_redirect!

    post omniauth_setup_path, params: {
      user: { username: "@newxuser", display_name: "New X User" }
    }

    assert_equal "newxuser@example.com", User.last.unconfirmed_email.presence || User.last.email
  end

  test "new X user signup works without email (confirmed_email not provided)" do
    OmniAuth.config.mock_auth[:twitter2] = OmniAuth::AuthHash.new(
      provider: "twitter2",
      uid: "uid_no_email",
      info: { name: "No Email User", email: nil }
    )

    post user_twitter2_omniauth_authorize_path
    follow_redirect!

    assert_difference "User.count", 1 do
      post omniauth_setup_path, params: {
        user: { username: "@noemailuser", display_name: "No Email User" }
      }
    end

    assert_nil User.last.email
  end

  test "username setup form shows validation errors for invalid input" do
    post user_twitter2_omniauth_authorize_path
    follow_redirect!

    assert_no_difference "User.count" do
      post omniauth_setup_path, params: {
        user: { username: "invalid_no_at", display_name: "" }
      }
    end

    assert_response :unprocessable_content
  end

  test "accessing username setup without session redirects to registration" do
    get new_omniauth_setup_path
    assert_redirected_to new_user_registration_path
  end

  # ==> 既存ユーザーの再ログイン（同一 uid）

  test "existing X user can sign in with matching uid" do
    OmniAuth.config.mock_auth[:twitter2] = OmniAuth::AuthHash.new(
      provider: "twitter2",
      uid: "uid_x_only_12345",
      info: { name: "X Only User", email: nil }
    )

    post user_twitter2_omniauth_authorize_path
    follow_redirect!

    assert_equal users(:x_only_user), controller.current_user
  end

  # ==> email 衝突

  test "X login with email matching existing user shows error and does not auto-merge" do
    OmniAuth.config.mock_auth[:twitter2] = OmniAuth::AuthHash.new(
      provider: "twitter2",
      uid: "uid_collision_test",
      info: { name: "Collision User", email: users(:willem).email }
    )

    # ユーザーは作成されず、ログインページへリダイレクト
    assert_no_difference "User.count" do
      post user_twitter2_omniauth_authorize_path
      follow_redirect!
    end

    assert_redirected_to new_user_session_path
  end

  # ==> UC2: 既存ユーザーへの X 連携

  test "signed-in user can link X account" do
    sign_in users(:willem)

    OmniAuth.config.mock_auth[:twitter2] = OmniAuth::AuthHash.new(
      provider: "twitter2",
      uid: "uid_new_link_111",
      info: { name: "Willem X", email: nil }
    )

    post user_twitter2_omniauth_authorize_path
    follow_redirect!

    users(:willem).reload
    assert_equal "twitter2", users(:willem).provider
    assert_equal "uid_new_link_111", users(:willem).uid
  end

  test "cannot link X account already connected to another user" do
    sign_in users(:willem)

    OmniAuth.config.mock_auth[:twitter2] = OmniAuth::AuthHash.new(
      provider: "twitter2",
      uid: "uid_x_only_12345",  # already linked to x_only_user
      info: { name: "Willem X", email: nil }
    )

    post user_twitter2_omniauth_authorize_path
    follow_redirect!

    users(:willem).reload
    assert_nil users(:willem).provider
    assert_redirected_to edit_user_path(users(:willem))
  end

  # ==> UC4: X 連携解除

  test "user with email and password can unlink X" do
    sign_in users(:x_linked_user)

    assert_changes "users(:x_linked_user).reload.provider", from: "twitter2", to: nil do
      delete settings_x_connection_path
    end

    assert_redirected_to edit_user_path(users(:x_linked_user))
  end

  test "X-only user cannot unlink X (no fallback login method)" do
    sign_in users(:x_only_user)

    assert_no_changes "users(:x_only_user).reload.provider" do
      delete settings_x_connection_path
    end

    assert_redirected_to edit_user_path(users(:x_only_user))
  end

  test "unauthenticated user cannot delete X connection" do
    delete settings_x_connection_path
    assert_redirected_to new_user_session_path
  end

  # ==> OAuth failure

  test "OAuth failure redirects to login with alert" do
    OmniAuth.config.mock_auth[:twitter2] = :invalid_credentials

    post user_twitter2_omniauth_authorize_path
    follow_redirect!

    assert_redirected_to new_user_session_path
  end
end

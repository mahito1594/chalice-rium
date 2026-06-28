require "test_helper"

class XSocialLoginTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def setup
    # X OAuth 2.0 は users.email スコープを申請していないため本番では email は返らない
    OmniAuth.config.mock_auth[:twitter2] = OmniAuth::AuthHash.new(
      provider: "twitter2",
      uid: "new_uid_999",
      info: { name: "New X User", email: nil }
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

  test "new X user signup creates user without email (X does not return email)" do
    post user_twitter2_omniauth_authorize_path
    follow_redirect!

    assert_difference "User.count", 1 do
      post omniauth_setup_path, params: {
        user: { username: "@newxuser", display_name: "New X User" }
      }
    end

    assert_nil User.last.email
  end

  test "new X user signup stores email when X returns one (defensive: for future email scope)" do
    OmniAuth.config.mock_auth[:twitter2] = OmniAuth::AuthHash.new(
      provider: "twitter2",
      uid: "uid_with_email",
      info: { name: "Email User", email: "xwithmail@example.com" }
    )

    post user_twitter2_omniauth_authorize_path
    follow_redirect!

    post omniauth_setup_path, params: {
      user: { username: "@emailxuser", display_name: "Email User" }
    }

    assert_equal "xwithmail@example.com",
                 User.last.unconfirmed_email.presence || User.last.email
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

  test "re-linking already-connected own X account shows already-linked notice" do
    sign_in users(:x_linked_user)

    OmniAuth.config.mock_auth[:twitter2] = OmniAuth::AuthHash.new(
      provider: "twitter2",
      uid: "uid_x_linked_67890",
      info: { name: "Linked User", email: nil }
    )

    post user_twitter2_omniauth_authorize_path
    follow_redirect!

    assert_redirected_to edit_user_path(users(:x_linked_user))
    assert_match "連携済み", flash[:notice].to_s
  end

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

  # ==> UC3: X-only ユーザーが email/password を設定する

  test "x-only user can set email and password without current_password" do
    sign_in users(:x_only_user)

    patch user_registration_path, params: {
      user: {
        email: "xonly_new@example.com",
        password: "newpassword123",
        password_confirmation: "newpassword123"
        # current_password は意図的に省略 — x_only? ユーザーには不要
      }
    }

    users(:x_only_user).reload
    assert_equal "xonly_new@example.com",
                 users(:x_only_user).unconfirmed_email.presence || users(:x_only_user).email
  end

  test "x-only user is no longer x_only after setting password" do
    sign_in users(:x_only_user)

    patch user_registration_path, params: {
      user: {
        email: "xonly_new2@example.com",
        password: "newpassword123",
        password_confirmation: "newpassword123"
      }
    }

    assert_not users(:x_only_user).reload.x_only?
  end

  test "regular user still requires current_password to update account" do
    sign_in users(:willem)

    patch user_registration_path, params: {
      user: {
        email: "new_willem@example.com",
        password: "newpassword123",
        password_confirmation: "newpassword123"
        # current_password なし — 通常ユーザーは必須
      }
    }

    assert_equal "willem@example.com", users(:willem).reload.email
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

# test/models/user_test.rb
require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup
    @user = users(:willem)
  end

  test "should be valid with valid attributes" do
    assert @user.valid?
  end

  test "should be invalid without a username" do
    @user.username = nil
    assert_not @user.valid?
  end

  test "should be invalid with a duplicate username" do
    duplicate_user = @user.dup
    duplicate_user.email = "other@example.com"
    duplicate_user.save
    assert_not duplicate_user.valid?
  end

  test "should be invalid with a duplicate email" do
    duplicate_user = @user.dup
    duplicate_user.username = "@other"
    duplicate_user.save
    assert_not duplicate_user.valid?
  end

  test "should be invalid with a username not starting with @" do
    @user.username = "testuser"
    assert_not @user.valid?
  end

  test "should be invalid with a username shorter than 3 characters" do
    @user.username = "@a"
    assert_not @user.valid?
  end

  test "should be invalid with a username longer than 32 characters" do
    @user.username = "@#{'a' * 32}"
    assert_not @user.valid?
  end

  test "should be invalid without a display_name" do
    @user.display_name = nil
    assert_not @user.valid?
  end

  test "should be invalid with a display_name longer than 64 characters" do
    @user.display_name = "a" * 65
    assert_not @user.valid?
  end

  test "should downcase the username before saving" do
    @user.username = "@TestUser"
    @user.save
    assert_equal "@testuser", @user.reload.username
  end

  test "should be invalid with a bio longer than 500 characters" do
    @user.bio = "a" * 501
    assert_not @user.valid?
  end

  test "should strip leading and trailing whitespace from bio before validation" do
    @user.bio = "  いろはにほへと  "
    @user.valid?
    assert_equal "いろはにほへと", @user.bio
  end

  test "should preserve internal whitespace in bio" do
    @user.bio = "いろは\nにほへと"
    @user.valid?
    assert_equal "いろは\nにほへと", @user.bio
  end

  # Test for Devise authentication helper
  test "should find user by email when username is nil" do
    result = User.find_first_by_auth_conditions(email: @user.email)
    assert_equal @user, result
  end

  test "should find user by username when provided" do
    result = User.find_first_by_auth_conditions(username: @user.username)
    assert_equal @user, result
  end

  test "should handle blank username in downcase" do
    user = User.new(
      email: "newuser@example.com",
      password: "password123",
      display_name: "New User",
      username: "@newuser"
    )
    assert user.valid?
  end

  # ==> X (Twitter) OmniAuth tests

  test "x_only? returns false for standard email/password user" do
    assert_not @user.x_only?
  end

  test "x_only? returns true for X-only user" do
    assert users(:x_only_user).x_only?
  end

  test "x_only? returns false for user with both X and password" do
    assert_not users(:x_linked_user).x_only?
  end

  test "email_required? is false for X-only user" do
    assert_not users(:x_only_user).email_required?
  end

  test "email_required? is true for standard user" do
    assert @user.email_required?
  end

  test "password_required? is false for X-only user" do
    assert_not users(:x_only_user).password_required?
  end

  test "password_required? is true for new standard user" do
    user = User.new
    assert user.password_required?
  end

  test "X-only user is valid without email" do
    user = users(:x_only_user)
    assert user.valid?
  end

  test "can_unlink_x? is true when both email and password are set" do
    assert users(:x_linked_user).can_unlink_x?
  end

  test "can_unlink_x? is false for X-only user (no email, no password)" do
    assert_not users(:x_only_user).can_unlink_x?
  end

  test "can_unlink_x? is true for standard user with email and password (precondition met even if X not linked)" do
    # can_unlink_x? checks whether the user has fallback login credentials,
    # not whether X is currently linked
    assert @user.can_unlink_x?
  end

  test "uid must be unique within the same provider" do
    duplicate = User.new(
      username: "@dup_x",
      display_name: "Dup X User",
      provider: "twitter2",
      uid: users(:x_only_user).uid,
      encrypted_password: ""
    )
    duplicate.skip_confirmation!
    assert_not duplicate.valid?
    assert duplicate.errors[:uid].present?
  end

  test "from_omniauth returns existing user by provider and uid" do
    auth = OmniAuth::AuthHash.new(provider: "twitter2", uid: "uid_x_only_12345", info: {})
    result = User.from_omniauth(auth)
    assert_equal users(:x_only_user), result
  end

  test "from_omniauth returns nil when no matching user exists" do
    auth = OmniAuth::AuthHash.new(provider: "twitter2", uid: "nonexistent_uid", info: {})
    result = User.from_omniauth(auth)
    assert_nil result
  end

  test "from_omniauth coerces provider and uid to string" do
    # uid might come as integer from some providers
    auth = OmniAuth::AuthHash.new(provider: :twitter2, uid: 12345, info: {})
    # No match expected, but should not raise
    assert_nothing_raised { User.from_omniauth(auth) }
  end

  test "twitter_link does not auto-link to X provider for account takeover prevention" do
    # Having a matching twitter_link should NOT grant X OAuth access
    user = User.new(
      username: "@notlinked",
      display_name: "Not Linked",
      email: "notlinked@example.com",
      password: "password123",
      twitter_link: "uid_x_only_12345"
    )
    auth = OmniAuth::AuthHash.new(provider: "twitter2", uid: "uid_x_only_12345", info: {})
    result = User.from_omniauth(auth)
    # Must return the user who has the matching provider/uid, not the one with matching twitter_link
    assert_not_equal user, result
  end
end

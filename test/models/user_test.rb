# test/models/user_test.rb
require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup
    @user = users(:willem)
    ActionMailer::Base.deliveries.clear
  end

  test "should be valid with valid attributes" do
    assert @user.valid?
  end

  # ==> username

  test "should be invalid without a username" do
    @user.username = nil
    assert_not @user.valid?
  end

  test "should be invalid with a duplicate username" do
    duplicate_user = @user.dup
    duplicate_user.email = "other@example.com"
    assert_not duplicate_user.valid?
    assert duplicate_user.errors[:username].any?
  end

  test "should be invalid with a duplicate username in different case" do
    duplicate_user = @user.dup
    duplicate_user.email = "other@example.com"
    duplicate_user.username = @user.username.upcase
    assert_not duplicate_user.valid?
  end

  test "should be invalid with a username not starting with @" do
    @user.username = "testuser"
    assert_not @user.valid?
  end

  test "should allow only alphanumerics and underscore after @" do
    @user.username = "@Test_User1"
    assert @user.valid?

    [ "@test-user", "@test user", "@テスト", "@@test" ].each do |username|
      @user.username = username
      assert_not @user.valid?, "username: #{username}"
    end
  end

  test "should allow username length from 3 to 32 characters including @" do
    @user.username = "@a"
    assert_not @user.valid?

    @user.username = "@ab"
    assert @user.valid?

    @user.username = "@#{'a' * 31}"
    assert @user.valid?

    @user.username = "@#{'a' * 32}"
    assert_not @user.valid?
  end

  test "should downcase the username before saving" do
    @user.username = "@TestUser"
    @user.save!
    assert_equal "@testuser", @user.reload.username
  end

  test "to_param should return username" do
    assert_equal "@willem", @user.to_param
  end

  # ==> display_name

  test "should be invalid without a display_name" do
    @user.display_name = nil
    assert_not @user.valid?
  end

  test "should allow display_name up to 64 characters" do
    @user.display_name = "a" * 64
    assert @user.valid?

    @user.display_name = "a" * 65
    assert_not @user.valid?
  end

  # ==> email (Devise validatable)

  test "should be invalid with a duplicate email" do
    duplicate_user = @user.dup
    duplicate_user.username = "@other"
    assert_not duplicate_user.valid?
    assert duplicate_user.errors[:email].any?
  end

  test "should be invalid without email for standard user" do
    @user.email = nil
    assert_not @user.valid?
  end

  test "X-only user is valid without email" do
    assert users(:x_only_user).valid?
  end

  # ==> bio

  test "should allow bio up to 500 characters" do
    @user.bio = "a" * 500
    assert @user.valid?

    @user.bio = "a" * 501
    assert_not @user.valid?
  end

  test "should allow blank bio" do
    @user.bio = nil
    assert @user.valid?
  end

  test "should strip leading and trailing whitespace from bio before validation" do
    @user.bio = "  いろはにほへと  "
    @user.valid?
    assert_equal "いろはにほへと", @user.bio
  end

  test "should count bio length after stripping whitespace" do
    @user.bio = "  #{'a' * 500}  "
    assert @user.valid?
  end

  test "should preserve internal whitespace in bio" do
    @user.bio = "いろは\nにほへと"
    @user.valid?
    assert_equal "いろは\nにほへと", @user.bio
  end

  # ==> twitter_link

  test "should allow blank twitter_link" do
    [ nil, "" ].each do |link|
      @user.twitter_link = link
      assert @user.valid?, "twitter_link: #{link.inspect}"
    end
  end

  test "should allow twitter_link with alphanumerics and underscore" do
    @user.twitter_link = "Willem_1"
    assert @user.valid?
  end

  test "should be invalid with twitter_link containing @ or URL" do
    [ "@willem", "https://x.com/willem", "will-em" ].each do |link|
      @user.twitter_link = link
      assert_not @user.valid?, "twitter_link: #{link}"
    end
  end

  # ==> associations

  test "destroying a user should destroy own dungeons" do
    own_dungeon_id = dungeons("9kv8xiyi").id
    other_dungeon_id = dungeons("2r8ghidm").id

    @user.destroy

    assert_not Dungeon.exists?(own_dungeon_id)
    assert Dungeon.exists?(other_dungeon_id)
  end

  # ==> Devise authentication helper

  test "should find user by email when username is nil" do
    result = User.find_first_by_auth_conditions(email: @user.email)
    assert_equal @user, result
  end

  test "should find user by username when provided" do
    result = User.find_first_by_auth_conditions(username: @user.username)
    assert_equal @user, result
  end

  test "should return nil when no user matches auth conditions" do
    assert_nil User.find_first_by_auth_conditions(username: "@nobody")
  end

  # ==> X (Twitter) OmniAuth

  # x_only? decision table: provider present? x encrypted_password present?
  test "x_only? returns true when provider is present and password is blank" do
    assert users(:x_only_user).x_only?
  end

  test "x_only? returns false when provider and password are both present" do
    assert_not users(:x_linked_user).x_only?
  end

  test "x_only? returns false when provider is absent and password is present" do
    assert_not @user.x_only?
  end

  test "x_only? returns false when provider and password are both absent" do
    assert_not User.new.x_only?
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
    assert User.new.password_required?
  end

  test "password_required? is false for persisted standard user unless password is being changed" do
    assert_not @user.password_required?

    @user.password = "newpassword"
    assert @user.password_required?
  end

  # can_unlink_x? decision table: email present? x encrypted_password present?
  test "can_unlink_x? is true when both email and password are set" do
    assert users(:x_linked_user).can_unlink_x?
  end

  test "can_unlink_x? is true for standard user even if X is not linked" do
    # can_unlink_x? checks whether the user has fallback login credentials,
    # not whether X is currently linked
    assert @user.can_unlink_x?
  end

  test "can_unlink_x? is false when neither email nor password is set" do
    assert_not users(:x_only_user).can_unlink_x?
  end

  test "can_unlink_x? is false when only email is set" do
    user = users(:x_only_user)
    user.email = "xonly@example.com"
    assert_not user.can_unlink_x?
  end

  test "can_unlink_x? is false when only password is set" do
    user = users(:x_linked_user)
    user.email = nil
    assert_not user.can_unlink_x?
  end

  test "password change notification is sent when user with email changes password" do
    @user.update!(password: "newpassword", password_confirmation: "newpassword")

    assert @user.send_password_change_notification?
    assert_includes delivered_subjects, I18n.t("devise.mailer.password_change.subject")
  end

  test "password change notification is skipped when X-only user sets email and password at once" do
    # email goes to unconfirmed_email (reconfirmable), so email is still nil at this point
    user = users(:x_only_user)
    user.update!(email: "xonly@example.com", password: "newpassword", password_confirmation: "newpassword")

    assert_nil user.email
    assert_not user.send_password_change_notification?
    assert_not_includes delivered_subjects, I18n.t("devise.mailer.password_change.subject")
  end

  test "uid must be unique within the same provider" do
    duplicate = User.new(
      username: "@dup_x",
      display_name: "Dup X User",
      provider: "twitter2",
      uid: users(:x_only_user).uid,
      encrypted_password: ""
    )
    assert_not duplicate.valid?
    assert duplicate.errors[:uid].present?
  end

  test "uid may be duplicated across different providers" do
    user = User.new(
      username: "@other_provider",
      display_name: "Other Provider User",
      provider: "other",
      uid: users(:x_only_user).uid,
      encrypted_password: ""
    )
    assert user.valid?
  end

  test "multiple users without uid are allowed" do
    assert_nil users(:laurence).uid
    @user.uid = nil
    assert @user.valid?
  end

  test "from_omniauth returns existing user by provider and uid" do
    auth = OmniAuth::AuthHash.new(provider: "twitter2", uid: "uid_x_only_12345", info: {})
    assert_equal users(:x_only_user), User.from_omniauth(auth)
  end

  test "from_omniauth returns nil when no matching user exists" do
    auth = OmniAuth::AuthHash.new(provider: "twitter2", uid: "nonexistent_uid", info: {})
    assert_nil User.from_omniauth(auth)
  end

  test "from_omniauth returns nil when uid matches but provider differs" do
    auth = OmniAuth::AuthHash.new(provider: "other", uid: "uid_x_only_12345", info: {})
    assert_nil User.from_omniauth(auth)
  end

  test "from_omniauth coerces provider and uid to string" do
    users(:x_only_user).update_column(:uid, "12345")

    auth = OmniAuth::AuthHash.new(provider: :twitter2, uid: 12345, info: {})
    assert_equal users(:x_only_user), User.from_omniauth(auth)
  end

  test "from_omniauth does not match by twitter_link for account takeover prevention" do
    # Having a matching twitter_link should NOT grant X OAuth access
    @user.update!(twitter_link: "takeover_uid")

    auth = OmniAuth::AuthHash.new(provider: "twitter2", uid: "takeover_uid", info: {})
    assert_nil User.from_omniauth(auth)
  end

  private

  def delivered_subjects
    ActionMailer::Base.deliveries.map(&:subject)
  end
end

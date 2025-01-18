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
end

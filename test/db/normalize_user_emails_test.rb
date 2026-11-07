require "test_helper"
require Rails.root.join("db/migrate/20261104000001_normalize_user_emails")

# Data migration for issue #426: existing emails saved before email was added to
# Devise's case_insensitive_keys / strip_whitespace_keys must be normalized.
class NormalizeUserEmailsTest < ActiveSupport::TestCase
  # Reads and writes bypass User's `normalizes :email`, which would otherwise normalize
  # the legacy values before the migration ever sees them.
  RawUser = NormalizeUserEmails::MigrationUser

  def migrate_up
    ActiveRecord::Migration.suppress_messages { NormalizeUserEmails.new.migrate(:up) }
  end

  def write_raw(fixture, **columns)
    RawUser.where(id: users(fixture).id).update_all(columns)
  end

  def read_raw(fixture, column = :email)
    RawUser.where(id: users(fixture).id).pick(column)
  end

  test "downcases and strips existing email and unconfirmed_email" do
    write_raw(:willem, email: " Willem@Example.COM ", unconfirmed_email: "New@Example.com")

    migrate_up

    assert_equal "willem@example.com", read_raw(:willem)
    assert_equal "new@example.com", read_raw(:willem, :unconfirmed_email)
  end

  test "normalizes email even when unconfirmed_email is nil" do
    write_raw(:willem, email: "Willem@Example.com", unconfirmed_email: nil)

    migrate_up

    assert_equal "willem@example.com", read_raw(:willem)
    assert_nil read_raw(:willem, :unconfirmed_email)
  end

  test "turns blank emails into NULL without treating them as a collision" do
    write_raw(:willem, email: "  ")
    write_raw(:laurence, email: " ")

    migrate_up

    assert_nil read_raw(:willem)
    assert_nil read_raw(:laurence)
  end

  test "leaves already-normalized and nil emails untouched" do
    migrate_up

    assert_equal "laurence@example.com", read_raw(:laurence)
    assert_nil read_raw(:x_only_user)
  end

  test "aborts without changing anything when normalization would collide" do
    write_raw(:laurence, email: "WILLEM@example.com")

    error = assert_raises(StandardError) { migrate_up }
    assert_match users(:willem).id.to_s, error.message
    assert_match users(:laurence).id.to_s, error.message
    assert_no_match(/@/, error.message)
    assert_equal "WILLEM@example.com", read_raw(:laurence)
  end
end

require "test_helper"
require Rails.root.join("db/migrate/20261104000001_normalize_user_emails")

# Data migration for issue #426: existing emails saved before email was added to
# Devise's case_insensitive_keys / strip_whitespace_keys must be normalized.
class NormalizeUserEmailsTest < ActiveSupport::TestCase
  def migrate_up
    ActiveRecord::Migration.suppress_messages { NormalizeUserEmails.new.migrate(:up) }
  end

  test "downcases and strips existing email and unconfirmed_email" do
    user = users(:willem)
    user.update_columns(email: " Willem@Example.COM ", unconfirmed_email: "New@Example.com")

    migrate_up

    user.reload
    assert_equal "willem@example.com", user.email
    assert_equal "new@example.com", user.unconfirmed_email
  end

  test "leaves already-normalized and nil emails untouched" do
    migrate_up

    assert_equal "laurence@example.com", users(:laurence).reload.email
    assert_nil users(:x_only_user).reload.email
  end

  test "aborts without changing anything when normalization would collide" do
    users(:laurence).update_columns(email: "WILLEM@example.com")

    error = assert_raises(StandardError) { migrate_up }
    assert_match "willem@example.com", error.message
    assert_equal "WILLEM@example.com", users(:laurence).reload.email
  end
end

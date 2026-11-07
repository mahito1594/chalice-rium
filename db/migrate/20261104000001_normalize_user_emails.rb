# frozen_string_literal: true

# Issue #426: email was added to Devise's case_insensitive_keys / strip_whitespace_keys.
# Normalize existing rows so that
#   - the case-sensitive uniqueness check (validatable) and unique index work as a
#     case-insensitive guard, and
#   - the next save of a legacy user does not silently change the email via
#     Devise's downcase_keys (which would trigger an unexpected reconfirmation).
class NormalizeUserEmails < ActiveRecord::Migration[8.1]
  # Use a lightweight model so that this migration does not depend on app/models/user.rb.
  class MigrationUser < ActiveRecord::Base
    self.table_name = "users"
  end

  def up
    users = MigrationUser.where.not(email: nil).pluck(:id, :email)
    groups = users.group_by { |_id, email| normalize(email) }
    # Blank emails become NULL, which the unique index allows any number of times.
    collisions = groups.select { |email, rows| email && rows.size > 1 }
    if collisions.any?
      # User ids only: this message reaches deploy/boot logs, so it must not contain email addresses.
      details = collisions.values.map { |rows| "user ids: #{rows.map(&:first).join(', ')}" }
      raise "Cannot normalize emails: multiple users share the same email ignoring case/whitespace. " \
            "Resolve these manually and re-run the migration: #{details.join('; ')}"
    end

    %i[email unconfirmed_email].each do |column|
      MigrationUser.where.not(column => nil).pluck(:id, column).each do |id, value|
        MigrationUser.where(id: id).update_all(column => normalize(value))
      end
    end
  end

  def down
    # Original casing/whitespace is not recoverable, and normalized values remain valid.
  end

  private

  # Blank becomes NULL: the unique index allows many NULLs but only one "".
  def normalize(value)
    value.strip.downcase.presence
  end
end

# frozen_string_literal: true

class AddOmniauthToUsers < ActiveRecord::Migration[8.1]
  def up
    # X-only users have no email, so allow NULL
    change_column_null :users, :email, true
    change_column_default :users, :email, from: "", to: nil

    add_column :users, :provider, :string
    add_column :users, :uid, :string
    add_index :users, [ :provider, :uid ], unique: true

    # Both columns must be NULL or both non-NULL
    add_check_constraint :users, "(provider IS NULL) = (uid IS NULL)",
                         name: "check_provider_uid_consistency"

    # Normalize legacy empty-string emails to NULL
    # (unique index allows multiple NULLs but only one "")
    execute "UPDATE users SET email = NULL WHERE email = ''"
  end

  def down
    execute "UPDATE users SET email = '' WHERE email IS NULL"

    remove_check_constraint :users, name: "check_provider_uid_consistency"
    remove_index :users, [ :provider, :uid ]
    remove_column :users, :uid
    remove_column :users, :provider

    change_column_default :users, :email, from: nil, to: ""
    change_column_null :users, :email, false, ""
  end
end

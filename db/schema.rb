# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_01_01_114152) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "dungeon_rites", force: :cascade do |t|
    t.bigint "dungeon_id", null: false
    t.bigint "rite_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["dungeon_id", "rite_id"], name: "index_dungeon_rites_on_dungeon_id_and_rite_id", unique: true
    t.index ["dungeon_id"], name: "index_dungeon_rites_on_dungeon_id"
    t.index ["rite_id"], name: "index_dungeon_rites_on_rite_id"
  end

  create_table "dungeons", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "glyph", limit: 8, null: false
    t.integer "depth", null: false
    t.integer "area", null: false
    t.boolean "is_open"
    t.text "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["glyph"], name: "index_dungeons_on_glyph", unique: true
    t.index ["user_id"], name: "index_dungeons_on_user_id"
  end

  create_table "layers", force: :cascade do |t|
    t.bigint "dungeon_id", null: false
    t.integer "level"
    t.string "boss_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["dungeon_id", "level"], name: "index_layers_on_dungeon_id_and_level", unique: true
    t.index ["dungeon_id"], name: "index_layers_on_dungeon_id"
  end

  create_table "rites", force: :cascade do |t|
    t.integer "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "username", null: false
    t.string "display_name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "dungeon_rites", "dungeons"
  add_foreign_key "dungeon_rites", "rites"
  add_foreign_key "dungeons", "users"
  add_foreign_key "layers", "dungeons"
end

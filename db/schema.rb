# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20140428214726) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "addresses", force: true do |t|
    t.string   "encrypted_private_key"
    t.string   "public_key"
    t.string   "address"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "redeem_script"
  end

  add_index "addresses", ["address"], name: "index_addresses_on_address", using: :btree

  create_table "admins", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "admins", ["email"], name: "index_admins_on_email", unique: true, using: :btree
  add_index "admins", ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true, using: :btree

  create_table "rails_admin_histories", force: true do |t|
    t.text     "message"
    t.string   "username"
    t.integer  "item"
    t.string   "table"
    t.integer  "month",      limit: 2
    t.integer  "year",       limit: 8
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "rails_admin_histories", ["item", "table", "month", "year"], name: "index_rails_admin_histories", using: :btree

  create_table "transactions", force: true do |t|
    t.integer "tweet_tip_id", null: false
    t.integer "satoshis",     null: false
    t.string  "tx_hash",      null: false
  end

  create_table "tweet_tips", force: true do |t|
    t.string   "content"
    t.string   "screen_name"
    t.string   "api_tweet_id_str"
    t.integer  "recipient_id"
    t.integer  "sender_id"
    t.integer  "satoshis"
    t.string   "tx_hash"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "tx_hash_refund"
  end

  add_index "tweet_tips", ["content"], name: "index_tweet_tips_on_content", using: :btree

  create_table "users", force: true do |t|
    t.string   "screen_name"
    t.boolean  "authenticated", default: false
    t.string   "uid"
    t.string   "slug"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "reminded_at"
  end

  add_index "users", ["screen_name"], name: "index_users_on_screen_name", using: :btree
  add_index "users", ["slug"], name: "index_users_on_slug", using: :btree
  add_index "users", ["uid"], name: "index_users_on_uid", using: :btree

end

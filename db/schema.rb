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

ActiveRecord::Schema.define(version: 20140414031309) do

  create_table "contacts", force: true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "phone"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "group_id"
    t.integer  "user_id"
  end

  add_index "contacts", ["group_id"], name: "index_contacts_on_group_id", using: :btree
  add_index "contacts", ["user_id"], name: "index_contacts_on_user_id", using: :btree

  create_table "event_meta", force: true do |t|
    t.integer  "event_id"
    t.integer  "repeat_interval"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "repeat_start"
    t.integer  "user_id"
  end

  add_index "event_meta", ["event_id"], name: "index_event_meta_on_event_id", using: :btree
  add_index "event_meta", ["user_id"], name: "index_event_meta_on_user_id", using: :btree

  create_table "events", force: true do |t|
    t.string   "title"
    t.string   "type_event"
    t.string   "content"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.datetime "start_time"
    t.datetime "end_time"
    t.datetime "end_date"
    t.string   "days_of_week"
  end

  add_index "events", ["user_id"], name: "index_events_on_user_id", using: :btree

  create_table "group_contacts", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "message_id"
  end

  add_index "group_contacts", ["message_id"], name: "index_group_contacts_on_message_id", using: :btree
  add_index "group_contacts", ["user_id"], name: "index_group_contacts_on_user_id", using: :btree

  create_table "messages", force: true do |t|
    t.integer  "user_id"
    t.string   "text"
    t.string   "photo_url"
    t.string   "audio_url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "lng"
    t.string   "lat"
  end

  create_table "user_children", force: true do |t|
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
    t.datetime "confirmed_at"
    t.string   "confirmation_token"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.string   "authentication_token"
  end

  add_index "user_children", ["authentication_token"], name: "index_user_children_on_authentication_token", unique: true, using: :btree
  add_index "user_children", ["confirmation_token"], name: "index_user_children_on_confirmation_token", unique: true, using: :btree
  add_index "user_children", ["email"], name: "index_user_children_on_email", unique: true, using: :btree
  add_index "user_children", ["reset_password_token"], name: "index_user_children_on_reset_password_token", unique: true, using: :btree

  create_table "users", force: true do |t|
    t.string   "email",                  default: "",       null: false
    t.string   "encrypted_password",     default: "",       null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,        null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.string   "authentication_token"
    t.string   "creator_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type_user",              default: "normal"
    t.string   "first_name"
    t.string   "last_name"
  end

  add_index "users", ["authentication_token"], name: "index_users_on_authentication_token", unique: true, using: :btree
  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end

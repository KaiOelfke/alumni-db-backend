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

ActiveRecord::Schema.define(version: 20150324131703) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "groups", force: true do |t|
    t.string   "description"
    t.string   "picture"
    t.string   "name"
    t.boolean  "group_email_enabled"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "memberships", force: true do |t|
    t.boolean  "is_admin"
    t.date     "join_date"
    t.boolean  "group_email_subscribed"
    t.string   "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "email",                                 null: false
    t.string   "encrypted_password",       default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",            default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "country"
    t.string   "city"
    t.date     "date_of_birth"
    t.integer  "gender",                   default: 0
    t.integer  "program_type",             default: 0
    t.string   "institution"
    t.integer  "year_of_participation"
    t.string   "country_of_participation"
    t.string   "student_company_name"
    t.string   "university_name"
    t.string   "university_major"
    t.string   "founded_company_name"
    t.string   "current_company_name"
    t.string   "current_job_position"
    t.string   "interests"
    t.string   "short_bio"
    t.string   "alumni_position"
    t.date     "member_since"
    t.string   "facebook_url"
    t.string   "skype_id"
    t.string   "twitter_url"
    t.string   "linkedin_url"
    t.string   "mobile_phone"
    t.string   "avatar"
    t.string   "provider"
    t.string   "uid",                      default: "", null: false
    t.text     "tokens"
    t.boolean  "registered"
    t.boolean  "confirmed_email"
    t.boolean  "completed_profile"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_super_user"
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["uid"], name: "index_users_on_uid", unique: true, using: :btree

end

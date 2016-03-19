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

ActiveRecord::Schema.define(version: 20151209193631) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "discounts", force: true do |t|
    t.string   "name",                        null: false
    t.string   "code",                        null: false
    t.integer  "price",                       null: false
    t.string   "description", default: "",    null: false
    t.boolean  "delete_flag", default: false, null: false
    t.datetime "expiry_at"
    t.integer  "plan_id"
  end

  add_index "discounts", ["plan_id"], name: "index_discounts_on_plan_id", using: :btree

  create_table "groups", force: true do |t|
    t.string   "description"
    t.string   "picture"
    t.string   "name",                null: false
    t.boolean  "group_email_enabled"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "groups", ["name"], name: "index_groups_on_name", using: :btree

  create_table "memberships", force: true do |t|
    t.boolean  "is_admin",               default: false
    t.date     "join_date",                              null: false
    t.boolean  "group_email_subscribed", default: true
    t.string   "position"
    t.integer  "user_id"
    t.integer  "group_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "memberships", ["group_id"], name: "index_memberships_on_group_id", using: :btree
  add_index "memberships", ["join_date"], name: "index_memberships_on_join_date", using: :btree
  add_index "memberships", ["user_id"], name: "index_memberships_on_user_id", using: :btree

  create_table "plans", force: true do |t|
    t.string  "name",                        null: false
    t.integer "price",                       null: false
    t.boolean "default",                     null: false
    t.string  "description", default: "",    null: false
    t.boolean "delete_flag", default: false, null: false
  end

  create_table "subscriptions", force: true do |t|
    t.string   "braintree_transaction_id"
    t.datetime "created_at",               null: false
    t.integer  "plan_id"
    t.integer  "discount_id"
  end

  add_index "subscriptions", ["discount_id"], name: "index_subscriptions_on_discount_id", using: :btree
  add_index "subscriptions", ["plan_id"], name: "index_subscriptions_on_plan_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "email",                                    null: false
    t.string   "encrypted_password",       default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",            default: 0,     null: false
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
    t.string   "uid",                      default: "",    null: false
    t.text     "tokens"
    t.boolean  "registered"
    t.boolean  "confirmed_email"
    t.boolean  "completed_profile"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_super_user",            default: false
    t.string   "customer_id",              default: ""
    t.integer  "subscription_id"
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["uid"], name: "index_users_on_uid", unique: true, using: :btree

end

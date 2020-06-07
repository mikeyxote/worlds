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

ActiveRecord::Schema.define(version: 20200607142948) do

  create_table "activities", force: :cascade do |t|
    t.integer  "strava_id",         limit: 8
    t.integer  "user_id"
    t.string   "name"
    t.float    "distance"
    t.datetime "start_date"
    t.boolean  "trainer"
    t.integer  "strava_athlete_id", limit: 8
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.integer  "event_id"
    t.string   "polyline"
    t.string   "summary_polyline"
  end

  add_index "activities", ["event_id"], name: "index_activities_on_event_id"
  add_index "activities", ["user_id"], name: "index_activities_on_user_id"

  create_table "connections", force: :cascade do |t|
    t.integer  "activity_id"
    t.integer  "event_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "connections", ["activity_id"], name: "index_connections_on_activity_id"
  add_index "connections", ["event_id"], name: "index_connections_on_event_id"

  create_table "efforts", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "segment_id"
    t.datetime "start_date"
    t.integer  "elapsed_time"
    t.integer  "strava_id",          limit: 8
    t.integer  "strava_segment_id",  limit: 8
    t.integer  "strava_athlete_id",  limit: 8
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.integer  "strava_activity_id", limit: 8
    t.integer  "activity_id"
    t.datetime "stop_date"
  end

  add_index "efforts", ["activity_id"], name: "index_efforts_on_activity_id"
  add_index "efforts", ["segment_id"], name: "index_efforts_on_segment_id"
  add_index "efforts", ["user_id"], name: "index_efforts_on_user_id"

  create_table "events", force: :cascade do |t|
    t.string   "name"
    t.datetime "start_date"
    t.integer  "segment_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.string   "event_segments"
    t.integer  "user_id"
    t.integer  "series_id"
  end

  add_index "events", ["segment_id"], name: "index_events_on_segment_id"
  add_index "events", ["series_id"], name: "index_events_on_series_id"
  add_index "events", ["user_id"], name: "index_events_on_user_id"

  create_table "features", force: :cascade do |t|
    t.integer  "event_id"
    t.integer  "segment_id"
    t.string   "category"
    t.integer  "points"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "val"
  end

  add_index "features", ["event_id"], name: "index_features_on_event_id"
  add_index "features", ["segment_id"], name: "index_features_on_segment_id"

  create_table "managements", force: :cascade do |t|
    t.integer  "manager_id"
    t.integer  "managed_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "managements", ["managed_id"], name: "index_managements_on_managed_id"
  add_index "managements", ["manager_id", "managed_id"], name: "index_managements_on_manager_id_and_managed_id", unique: true
  add_index "managements", ["manager_id"], name: "index_managements_on_manager_id"

  create_table "memberships", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "team_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "memberships", ["team_id"], name: "index_memberships_on_team_id"
  add_index "memberships", ["user_id"], name: "index_memberships_on_user_id"

  create_table "participations", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "event_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "participations", ["event_id"], name: "index_participations_on_event_id"
  add_index "participations", ["user_id"], name: "index_participations_on_user_id"

  create_table "points", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "feature_id"
    t.integer  "effort_id"
    t.integer  "event_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "val"
    t.string   "category"
    t.integer  "place"
  end

  add_index "points", ["effort_id"], name: "index_points_on_effort_id"
  add_index "points", ["event_id"], name: "index_points_on_event_id"
  add_index "points", ["feature_id"], name: "index_points_on_feature_id"
  add_index "points", ["user_id"], name: "index_points_on_user_id"

  create_table "races", force: :cascade do |t|
    t.integer  "series_id"
    t.integer  "event_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "races", ["event_id"], name: "index_races_on_event_id"
  add_index "races", ["series_id"], name: "index_races_on_series_id"

  create_table "results", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "event_id"
    t.integer  "kom"
    t.integer  "sprint"
    t.integer  "finish"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "total"
    t.integer  "place"
    t.datetime "start_date"
  end

  add_index "results", ["event_id"], name: "index_results_on_event_id"
  add_index "results", ["user_id"], name: "index_results_on_user_id"

  create_table "segments", force: :cascade do |t|
    t.integer  "points"
    t.string   "name"
    t.integer  "strava_id",      limit: 8
    t.float    "max_grade"
    t.float    "average_grade"
    t.integer  "climb_category"
    t.integer  "star_count"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.float    "distance"
    t.float    "elevation_gain"
    t.string   "polyline"
    t.string   "endpoint"
  end

  create_table "series", force: :cascade do |t|
    t.string   "name"
    t.string   "description"
    t.datetime "start_date"
    t.datetime "end_date"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "teams", force: :cascade do |t|
    t.string   "name"
    t.string   "profile"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "firstname"
    t.string   "lastname"
    t.string   "username"
    t.string   "strava_token"
    t.string   "strava_refresh_token"
    t.integer  "strava_expiration"
    t.integer  "strava_id"
    t.boolean  "director",               default: false
    t.boolean  "developer",              default: false
    t.string   "profile_medium"
    t.string   "profile"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true

  create_table "weeklies", force: :cascade do |t|
    t.integer  "segment_id"
    t.datetime "start_date"
    t.datetime "end_date"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "team_id"
  end

  add_index "weeklies", ["segment_id"], name: "index_weeklies_on_segment_id"
  add_index "weeklies", ["team_id"], name: "index_weeklies_on_team_id"
  add_index "weeklies", ["user_id"], name: "index_weeklies_on_user_id"

end

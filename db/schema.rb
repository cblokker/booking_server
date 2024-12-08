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

ActiveRecord::Schema[8.0].define(version: 2024_12_04_054114) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "availability_slots", force: :cascade do |t|
    t.datetime "start_time", null: false
    t.datetime "end_time", null: false
    t.bigint "coach_id", null: false
    t.bigint "availability_window_id", null: false
    t.boolean "booked", default: false, null: false
    t.bigint "booking_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["availability_window_id"], name: "index_availability_slots_on_availability_window_id"
    t.index ["booking_id"], name: "index_availability_slots_on_booking_id"
    t.index ["coach_id", "start_time"], name: "index_availability_slots_on_coach_and_start", unique: true
  end

  create_table "availability_windows", force: :cascade do |t|
    t.jsonb "intervals", default: []
    t.integer "day_of_week", null: false
    t.bigint "coach_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["coach_id", "day_of_week"], name: "idx_on_coach_id_day_of_week", unique: true
    t.index ["coach_id"], name: "index_availability_windows_on_coach_id"
    t.index ["intervals"], name: "index_availability_windows_on_intervals", using: :gin
  end

  create_table "bookings", force: :cascade do |t|
    t.datetime "start_time", null: false
    t.datetime "end_time", null: false
    t.integer "status", default: 0, null: false
    t.integer "satisfaction_score"
    t.text "notes"
    t.bigint "student_id", null: false
    t.bigint "coach_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["coach_id"], name: "index_bookings_on_coach_id"
    t.index ["student_id"], name: "index_bookings_on_student_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.integer "role", default: 0, null: false
    t.string "phone_number", null: false
    t.string "image_url"
    t.string "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "availability_slots", "availability_windows"
  add_foreign_key "availability_slots", "bookings"
  add_foreign_key "availability_slots", "users", column: "coach_id"
  add_foreign_key "availability_windows", "users", column: "coach_id"
  add_foreign_key "bookings", "users", column: "coach_id"
  add_foreign_key "bookings", "users", column: "student_id"
end

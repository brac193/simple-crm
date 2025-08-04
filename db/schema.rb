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

ActiveRecord::Schema[8.0].define(version: 2025_08_04_122028) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  # Custom types defined in this database.
  # Note that some types may not work with other database engines. Be careful if changing database.
  create_enum "car_type", ["small", "city", "suv"]
  create_enum "user_role", ["admin", "user"]

  create_table "cars", force: :cascade do |t|
    t.string "make"
    t.string "model"
    t.integer "year"
    t.string "license_plate"
    t.decimal "daily_rate"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.enum "car_type", default: "small", null: false, enum_type: "car_type"
    t.integer "reservations_count", default: 0, null: false
    t.index ["car_type"], name: "index_cars_on_car_type"
    t.index ["reservations_count"], name: "index_cars_on_reservations_count"
  end

  create_table "clients", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "email"
    t.string "phone"
    t.bigint "company_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_clients_on_company_id"
  end

  create_table "companies", force: :cascade do |t|
    t.string "name"
    t.text "address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "clients_count", default: 0, null: false
    t.index ["clients_count"], name: "index_companies_on_clients_count"
  end

  create_table "invoices", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "reservation_id", null: false
    t.decimal "amount", precision: 10, scale: 2, default: "0.0", null: false
    t.decimal "penalty_amount", precision: 10, scale: 2, default: "0.0", null: false
    t.decimal "total_amount", precision: 10, scale: 2, default: "0.0", null: false
    t.string "status", default: "pending", null: false
    t.date "due_date", null: false
    t.datetime "paid_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["due_date"], name: "index_invoices_on_due_date"
    t.index ["reservation_id"], name: "index_invoices_on_reservation_id"
    t.index ["status"], name: "index_invoices_on_status"
    t.index ["user_id"], name: "index_invoices_on_user_id"
  end

  create_table "reservations", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "car_id", null: false
    t.date "start_date"
    t.date "end_date"
    t.decimal "total_price"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "returned_at"
    t.bigint "created_by_id"
    t.index ["car_id"], name: "index_reservations_on_car_id"
    t.index ["created_by_id"], name: "index_reservations_on_created_by_id"
    t.index ["returned_at"], name: "index_reservations_on_returned_at"
    t.index ["user_id"], name: "index_reservations_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.enum "role", default: "user", null: false, enum_type: "user_role"
    t.string "first_name"
    t.string "last_name"
    t.integer "reservations_count", default: 0, null: false
    t.integer "upcoming_reservations_count", default: 0, null: false
    t.integer "past_reservations_count", default: 0, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["past_reservations_count"], name: "index_users_on_past_reservations_count"
    t.index ["reservations_count"], name: "index_users_on_reservations_count"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["role"], name: "index_users_on_role"
    t.index ["upcoming_reservations_count"], name: "index_users_on_upcoming_reservations_count"
  end

  add_foreign_key "clients", "companies"
  add_foreign_key "invoices", "reservations"
  add_foreign_key "invoices", "users"
  add_foreign_key "reservations", "cars"
  add_foreign_key "reservations", "users"
  add_foreign_key "reservations", "users", column: "created_by_id"
end

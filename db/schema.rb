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

ActiveRecord::Schema.define(version: 2019_12_11_121846) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "cruises", force: :cascade do |t|
    t.bigint "line_id"
    t.string "code"
    t.date "start"
    t.integer "days"
    t.integer "price"
    t.string "cabin_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["line_id"], name: "index_cruises_on_line_id"
  end

  create_table "lines", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "ports", force: :cascade do |t|
    t.string "code"
    t.string "name"
    t.float "lat"
    t.float "lng"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "stops", force: :cascade do |t|
    t.bigint "cruise_id"
    t.bigint "port_id"
    t.datetime "d_from"
    t.datetime "d_to"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cruise_id"], name: "index_stops_on_cruise_id"
    t.index ["port_id"], name: "index_stops_on_port_id"
  end

  add_foreign_key "cruises", "lines"
  add_foreign_key "stops", "cruises"
  add_foreign_key "stops", "ports"
end

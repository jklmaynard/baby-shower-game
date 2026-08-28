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

ActiveRecord::Schema[8.1].define(version: 2026_08_28_172235) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "player_answers", force: :cascade do |t|
    t.string "answer_text"
    t.datetime "created_at", null: false
    t.boolean "is_correct", default: false
    t.bigint "player_id", null: false
    t.bigint "question_id", null: false
    t.datetime "updated_at", null: false
    t.index ["player_id", "question_id"], name: "index_player_answers_on_player_id_and_question_id", unique: true
    t.index ["player_id"], name: "index_player_answers_on_player_id"
    t.index ["question_id"], name: "index_player_answers_on_question_id"
  end

  create_table "players", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "passkey_digest"
    t.datetime "updated_at", null: false
  end

  create_table "questions", force: :cascade do |t|
    t.jsonb "answers", default: [], null: false
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.integer "position", default: 0, null: false
    t.integer "question_type", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["position"], name: "index_questions_on_position"
  end

  add_foreign_key "player_answers", "players"
  add_foreign_key "player_answers", "questions"
end

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

ActiveRecord::Schema[8.0].define(version: 2025_03_25_195454) do
  create_table "addresses", force: :cascade do |t|
    t.integer "zip"
    t.string "town"
    t.string "street"
    t.string "number"
    t.integer "person_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["person_id"], name: "index_addresses_on_person_id"
  end

  create_table "courses", force: :cascade do |t|
    t.string "term", null: false
    t.datetime "start_at", null: false
    t.datetime "end_at", null: false
    t.integer "week_day", null: false
    t.integer "school_class_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "subject_id", null: false
    t.index ["school_class_id"], name: "index_courses_on_school_class_id"
    t.index ["subject_id"], name: "index_courses_on_subject_id"
  end

  create_table "examinations", force: :cascade do |t|
    t.string "title"
    t.integer "course_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_id"], name: "index_examinations_on_course_id"
  end

  create_table "grades", force: :cascade do |t|
    t.decimal "value", precision: 5, scale: 2, null: false
    t.datetime "effective_date", null: false
    t.integer "person_id", null: false
    t.integer "examination_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["examination_id"], name: "index_grades_on_examination_id"
    t.index ["person_id"], name: "index_grades_on_person_id"
  end

  create_table "people", force: :cascade do |t|
    t.string "username"
    t.string "lastname"
    t.string "firstname"
    t.string "email"
    t.string "phone_number"
    t.string "type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "iban"
    t.integer "student_status_id"
    t.integer "teacher_status_id"
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.index ["email"], name: "index_people_on_email", unique: true
    t.index ["reset_password_token"], name: "index_people_on_reset_password_token", unique: true
    t.index ["student_status_id"], name: "index_people_on_student_status_id"
    t.index ["teacher_status_id"], name: "index_people_on_teacher_status_id"
  end

  create_table "people_school_classes", id: false, force: :cascade do |t|
    t.integer "school_class_id", null: false
    t.integer "person_id", null: false
    t.index ["person_id"], name: "index_people_school_classes_on_person_id"
    t.index ["school_class_id", "person_id"], name: "index_people_school_classes_on_school_class_id_and_person_id", unique: true
    t.index ["school_class_id"], name: "index_people_school_classes_on_school_class_id"
  end

  create_table "rooms", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_rooms_on_name", unique: true
  end

  create_table "school_classes", force: :cascade do |t|
    t.integer "year"
    t.string "name"
    t.integer "room_id", null: false
    t.integer "master_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["room_id"], name: "index_school_classes_on_room_id"
  end

  create_table "student_statuses", force: :cascade do |t|
    t.string "status", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "subjects", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_subjects_on_name", unique: true
  end

  create_table "teacher_statuses", force: :cascade do |t|
    t.string "status", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "addresses", "people"
  add_foreign_key "courses", "school_classes"
  add_foreign_key "courses", "subjects"
  add_foreign_key "examinations", "courses"
  add_foreign_key "grades", "examinations"
  add_foreign_key "grades", "people"
  add_foreign_key "people", "student_statuses"
  add_foreign_key "people", "teacher_statuses"
  add_foreign_key "people_school_classes", "people"
  add_foreign_key "people_school_classes", "school_classes"
  add_foreign_key "school_classes", "rooms"
end

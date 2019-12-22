# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2012_11_06_135728) do

  create_table "document_files", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "document_version_id"
    t.string "format"
    t.string "sha1"
    t.integer "size"
    t.integer "nb_pages"
    t.index ["document_version_id"], name: "index_document_files_on_document_version_id"
  end

  create_table "document_tocs", force: :cascade do |t|
    t.integer "parent_id"
    t.integer "document_file_id"
    t.integer "level"
    t.string "title"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "page"
  end

  create_table "document_versions", force: :cascade do |t|
    t.integer "major"
    t.integer "technical"
    t.integer "editorial"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "document_id"
    t.integer "release_id"
    t.index ["document_id"], name: "index_document_versions_on_document_id"
    t.index ["release_id"], name: "index_document_versions_on_release_id"
  end

  create_table "documents", force: :cascade do |t|
    t.string "name"
    t.string "title"
    t.integer "spec_serie_id"
    t.integer "spec_number"
    t.integer "spec_part"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "releases", force: :cascade do |t|
    t.string "name"
    t.integer "version"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "spec_scopes", force: :cascade do |t|
    t.string "scope"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "spec_series", force: :cascade do |t|
    t.integer "index"
    t.integer "spec_scope_id"
    t.string "subject"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

end

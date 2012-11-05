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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20121105120333) do

  create_table "document_files", :force => true do |t|
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
    t.integer  "document_version_id"
    t.string   "format"
    t.string   "sha1"
    t.integer  "size"
  end

  add_index "document_files", ["document_version_id"], :name => "index_document_files_on_document_version_id"

  create_table "document_versions", :force => true do |t|
    t.integer  "major"
    t.integer  "technical"
    t.integer  "editorial"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.integer  "document_id"
    t.integer  "release_id"
  end

  add_index "document_versions", ["document_id"], :name => "index_document_versions_on_document_id"
  add_index "document_versions", ["release_id"], :name => "index_document_versions_on_release_id"

  create_table "documents", :force => true do |t|
    t.string   "name"
    t.string   "title"
    t.integer  "spec_serie_id"
    t.integer  "spec_number"
    t.integer  "spec_part"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "releases", :force => true do |t|
    t.string   "name"
    t.integer  "version"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "spec_scopes", :force => true do |t|
    t.string   "scope"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "spec_series", :force => true do |t|
    t.integer  "index"
    t.integer  "spec_scope_id"
    t.string   "subject"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

end

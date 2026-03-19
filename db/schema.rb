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

ActiveRecord::Schema[8.1].define(version: 2026_03_19_191252) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "entries", force: :cascade do |t|
    t.jsonb "content", default: {}, null: false
    t.datetime "created_at", null: false
    t.integer "position", default: 0, null: false
    t.bigint "section_id", null: false
    t.datetime "updated_at", null: false
    t.index ["section_id", "position"], name: "index_entries_on_section_id_and_position"
    t.index ["section_id"], name: "index_entries_on_section_id"
  end

  create_table "job_logs", force: :cascade do |t|
    t.string "active_job_id"
    t.datetime "created_at", null: false
    t.integer "duration_ms"
    t.jsonb "error_details", default: {}, null: false
    t.datetime "finished_at"
    t.jsonb "input", default: {}, null: false
    t.string "job_type", null: false
    t.jsonb "output", default: {}, null: false
    t.string "queue_name", null: false
    t.datetime "started_at"
    t.string "status", null: false
    t.datetime "updated_at", null: false
    t.index ["active_job_id"], name: "index_job_logs_on_active_job_id", unique: true
    t.index ["created_at"], name: "index_job_logs_on_created_at"
    t.index ["job_type"], name: "index_job_logs_on_job_type"
    t.index ["status"], name: "index_job_logs_on_status"
  end

  create_table "llm_interactions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "error_message"
    t.string "feature_name", null: false
    t.integer "latency_ms"
    t.jsonb "metadata", default: {}, null: false
    t.text "prompt"
    t.text "response"
    t.bigint "resume_id", null: false
    t.string "status", null: false
    t.jsonb "token_usage", default: {}, null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["created_at"], name: "index_llm_interactions_on_created_at"
    t.index ["feature_name"], name: "index_llm_interactions_on_feature_name"
    t.index ["resume_id"], name: "index_llm_interactions_on_resume_id"
    t.index ["status"], name: "index_llm_interactions_on_status"
    t.index ["user_id"], name: "index_llm_interactions_on_user_id"
  end

  create_table "platform_settings", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.jsonb "feature_flags", default: {}, null: false
    t.string "name", null: false
    t.jsonb "preferences", default: {}, null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_platform_settings_on_name", unique: true
  end

  create_table "resumes", force: :cascade do |t|
    t.jsonb "contact_details", default: {}, null: false
    t.datetime "created_at", null: false
    t.string "headline"
    t.jsonb "settings", default: {}, null: false
    t.string "slug", null: false
    t.text "summary", default: "", null: false
    t.bigint "template_id", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["template_id"], name: "index_resumes_on_template_id"
    t.index ["user_id", "slug"], name: "index_resumes_on_user_id_and_slug", unique: true
    t.index ["user_id"], name: "index_resumes_on_user_id"
  end

  create_table "sections", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "position", default: 0, null: false
    t.bigint "resume_id", null: false
    t.string "section_type", null: false
    t.jsonb "settings", default: {}, null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["resume_id", "position"], name: "index_sections_on_resume_id_and_position"
    t.index ["resume_id", "section_type"], name: "index_sections_on_resume_id_and_section_type"
    t.index ["resume_id"], name: "index_sections_on_resume_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address", null: false
    t.datetime "updated_at", null: false
    t.string "user_agent", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "templates", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.text "description", default: "", null: false
    t.jsonb "layout_config", default: {}, null: false
    t.string "name", null: false
    t.string "slug", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_templates_on_active"
    t.index ["slug"], name: "index_templates_on_slug", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.integer "role", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "entries", "sections"
  add_foreign_key "llm_interactions", "resumes"
  add_foreign_key "llm_interactions", "users"
  add_foreign_key "resumes", "templates"
  add_foreign_key "resumes", "users"
  add_foreign_key "sections", "resumes"
  add_foreign_key "sessions", "users"
end

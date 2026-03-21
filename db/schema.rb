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

ActiveRecord::Schema[8.1].define(version: 2026_03_21_000200) do
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

  create_table "error_logs", force: :cascade do |t|
    t.jsonb "backtrace_lines", default: [], null: false
    t.jsonb "context", default: {}, null: false
    t.datetime "created_at", null: false
    t.integer "duration_ms"
    t.string "error_class", null: false
    t.text "message", null: false
    t.datetime "occurred_at", null: false
    t.string "reference_id", null: false
    t.string "source", null: false
    t.datetime "updated_at", null: false
    t.index ["error_class"], name: "index_error_logs_on_error_class"
    t.index ["occurred_at"], name: "index_error_logs_on_occurred_at"
    t.index ["reference_id"], name: "index_error_logs_on_reference_id", unique: true
    t.index ["source"], name: "index_error_logs_on_source"
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
    t.bigint "llm_model_id"
    t.bigint "llm_provider_id"
    t.jsonb "metadata", default: {}, null: false
    t.text "prompt"
    t.text "response"
    t.bigint "resume_id", null: false
    t.string "role"
    t.string "status", null: false
    t.jsonb "token_usage", default: {}, null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["created_at"], name: "index_llm_interactions_on_created_at"
    t.index ["feature_name"], name: "index_llm_interactions_on_feature_name"
    t.index ["llm_model_id"], name: "index_llm_interactions_on_llm_model_id"
    t.index ["llm_provider_id"], name: "index_llm_interactions_on_llm_provider_id"
    t.index ["resume_id"], name: "index_llm_interactions_on_resume_id"
    t.index ["role"], name: "index_llm_interactions_on_role"
    t.index ["status"], name: "index_llm_interactions_on_status"
    t.index ["user_id"], name: "index_llm_interactions_on_user_id"
  end

  create_table "llm_model_assignments", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "llm_model_id", null: false
    t.integer "position", default: 0, null: false
    t.string "role", null: false
    t.datetime "updated_at", null: false
    t.index ["llm_model_id", "role"], name: "index_llm_model_assignments_on_llm_model_id_and_role", unique: true
    t.index ["llm_model_id"], name: "index_llm_model_assignments_on_llm_model_id"
    t.index ["role", "position"], name: "index_llm_model_assignments_on_role_and_position"
  end

  create_table "llm_models", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.string "identifier", null: false
    t.bigint "llm_provider_id", null: false
    t.jsonb "metadata", default: {}, null: false
    t.string "name", null: false
    t.jsonb "settings", default: {}, null: false
    t.boolean "supports_text", default: true, null: false
    t.boolean "supports_vision", default: false, null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_llm_models_on_active"
    t.index ["llm_provider_id", "identifier"], name: "index_llm_models_on_llm_provider_id_and_identifier", unique: true
    t.index ["llm_provider_id"], name: "index_llm_models_on_llm_provider_id"
  end

  create_table "llm_providers", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.string "adapter", null: false
    t.string "api_key_env_var"
    t.string "base_url", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.jsonb "settings", default: {}, null: false
    t.string "slug", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_llm_providers_on_active"
    t.index ["slug"], name: "index_llm_providers_on_slug", unique: true
  end

  create_table "photo_assets", force: :cascade do |t|
    t.string "asset_kind", default: "source", null: false
    t.datetime "created_at", null: false
    t.jsonb "metadata", default: {}, null: false
    t.bigint "photo_profile_id", null: false
    t.bigint "source_asset_id"
    t.string "status", default: "uploaded", null: false
    t.datetime "updated_at", null: false
    t.index ["photo_profile_id", "asset_kind"], name: "index_photo_assets_on_photo_profile_id_and_asset_kind"
    t.index ["photo_profile_id"], name: "index_photo_assets_on_photo_profile_id"
    t.index ["source_asset_id"], name: "index_photo_assets_on_source_asset_id"
    t.index ["status"], name: "index_photo_assets_on_status"
  end

  create_table "photo_processing_runs", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "error_summary"
    t.datetime "finished_at"
    t.jsonb "input_asset_ids", default: [], null: false
    t.bigint "job_log_id"
    t.jsonb "metadata", default: {}, null: false
    t.text "next_step_guidance"
    t.jsonb "output_asset_ids", default: [], null: false
    t.bigint "photo_profile_id", null: false
    t.text "prompt_text"
    t.jsonb "request_payload", default: {}, null: false
    t.jsonb "response_payload", default: {}, null: false
    t.bigint "resume_id"
    t.jsonb "selected_model_ids", default: [], null: false
    t.datetime "started_at"
    t.string "status", default: "queued", null: false
    t.bigint "template_id"
    t.datetime "updated_at", null: false
    t.string "workflow_type", null: false
    t.index ["created_at"], name: "index_photo_processing_runs_on_created_at"
    t.index ["job_log_id"], name: "index_photo_processing_runs_on_job_log_id"
    t.index ["photo_profile_id"], name: "index_photo_processing_runs_on_photo_profile_id"
    t.index ["resume_id"], name: "index_photo_processing_runs_on_resume_id"
    t.index ["status"], name: "index_photo_processing_runs_on_status"
    t.index ["template_id"], name: "index_photo_processing_runs_on_template_id"
    t.index ["workflow_type"], name: "index_photo_processing_runs_on_workflow_type"
  end

  create_table "photo_profiles", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.text "notes"
    t.jsonb "preferences", default: {}, null: false
    t.bigint "selected_source_photo_asset_id"
    t.string "status", default: "draft", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["selected_source_photo_asset_id"], name: "index_photo_profiles_on_selected_source_photo_asset_id"
    t.index ["status"], name: "index_photo_profiles_on_status"
    t.index ["user_id", "name"], name: "index_photo_profiles_on_user_id_and_name"
    t.index ["user_id"], name: "index_photo_profiles_on_user_id"
  end

  create_table "platform_settings", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.jsonb "feature_flags", default: {}, null: false
    t.string "name", null: false
    t.jsonb "preferences", default: {}, null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_platform_settings_on_name", unique: true
  end

  create_table "resume_photo_selections", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "photo_asset_id", null: false
    t.bigint "resume_id", null: false
    t.string "slot_name", null: false
    t.string "status", default: "active", null: false
    t.bigint "template_id", null: false
    t.datetime "updated_at", null: false
    t.index ["photo_asset_id"], name: "index_resume_photo_selections_on_photo_asset_id"
    t.index ["resume_id", "template_id", "slot_name"], name: "index_resume_photo_selections_on_resume_template_slot", unique: true
    t.index ["resume_id"], name: "index_resume_photo_selections_on_resume_id"
    t.index ["template_id"], name: "index_resume_photo_selections_on_template_id"
  end

  create_table "resumes", force: :cascade do |t|
    t.jsonb "contact_details", default: {}, null: false
    t.datetime "created_at", null: false
    t.string "headline"
    t.jsonb "intake_details", default: {}, null: false
    t.jsonb "personal_details", default: {}, null: false
    t.bigint "photo_profile_id"
    t.jsonb "settings", default: {}, null: false
    t.string "slug", null: false
    t.string "source_mode", default: "scratch", null: false
    t.text "source_text"
    t.text "summary", default: "", null: false
    t.bigint "template_id", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["photo_profile_id"], name: "index_resumes_on_photo_profile_id"
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
  add_foreign_key "llm_interactions", "llm_models"
  add_foreign_key "llm_interactions", "llm_providers"
  add_foreign_key "llm_interactions", "resumes"
  add_foreign_key "llm_interactions", "users"
  add_foreign_key "llm_model_assignments", "llm_models"
  add_foreign_key "llm_models", "llm_providers"
  add_foreign_key "photo_assets", "photo_assets", column: "source_asset_id"
  add_foreign_key "photo_assets", "photo_profiles"
  add_foreign_key "photo_processing_runs", "job_logs"
  add_foreign_key "photo_processing_runs", "photo_profiles"
  add_foreign_key "photo_processing_runs", "resumes"
  add_foreign_key "photo_processing_runs", "templates"
  add_foreign_key "photo_profiles", "photo_assets", column: "selected_source_photo_asset_id"
  add_foreign_key "photo_profiles", "users"
  add_foreign_key "resume_photo_selections", "photo_assets"
  add_foreign_key "resume_photo_selections", "resumes"
  add_foreign_key "resume_photo_selections", "templates"
  add_foreign_key "resumes", "photo_profiles"
  add_foreign_key "resumes", "templates"
  add_foreign_key "resumes", "users"
  add_foreign_key "sections", "resumes"
  add_foreign_key "sessions", "users"
end

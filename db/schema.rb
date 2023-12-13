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

ActiveRecord::Schema[7.1].define(version: 2023_12_12_234448) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "artist_submissions", force: :cascade do |t|
    t.bigint "artist_url_id", null: false
    t.text "identifier_on_site", null: false
    t.text "title_on_site", null: false
    t.text "description_on_site", null: false
    t.datetime "created_at_on_site", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index "artist_url_id, lower(identifier_on_site)", name: "index_artist_submissions_on_artist_url_and_identifier", unique: true
    t.index ["artist_url_id"], name: "index_artist_submissions_on_artist_url_id"
  end

  create_table "artist_urls", force: :cascade do |t|
    t.bigint "artist_id", null: false
    t.text "url_identifier", null: false
    t.datetime "created_at_on_site", null: false
    t.text "about_on_site", null: false
    t.boolean "scraping_disabled", default: false, null: false
    t.datetime "last_scraped_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "api_identifier"
    t.integer "site_type", null: false
    t.jsonb "scraper_status", default: {}, null: false
    t.index "site_type, lower(url_identifier)", name: "index_artist_urls_on_site_and_url_identifier", unique: true
    t.index ["artist_id"], name: "index_artist_urls_on_artist_id"
    t.index ["site_type", "api_identifier"], name: "index_site_type_on_api_identifier", unique: true
    t.index ["url_identifier"], name: "index_artist_urls_on_url_identifier"
  end

  create_table "artists", force: :cascade do |t|
    t.text "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_commissioner", default: false, null: false
    t.string "e621_tag"
    t.index "lower(name)", name: "index_artists_on_lower_name", unique: true
  end

  create_table "e6_posts", force: :cascade do |t|
    t.bigint "submission_file_id", null: false
    t.integer "post_id", null: false
    t.integer "post_width", null: false
    t.integer "post_height", null: false
    t.integer "post_size", null: false
    t.float "similarity_score", null: false
    t.boolean "is_exact_match", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "post_json", null: false
    t.boolean "post_is_deleted", null: false
    t.index ["submission_file_id"], name: "index_e6_posts_on_submission_file_id"
  end

  create_table "good_job_batches", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "description"
    t.jsonb "serialized_properties"
    t.text "on_finish"
    t.text "on_success"
    t.text "on_discard"
    t.text "callback_queue_name"
    t.integer "callback_priority"
    t.datetime "enqueued_at"
    t.datetime "discarded_at"
    t.datetime "finished_at"
  end

  create_table "good_job_executions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "active_job_id", null: false
    t.text "job_class"
    t.text "queue_name"
    t.jsonb "serialized_params"
    t.datetime "scheduled_at"
    t.datetime "finished_at"
    t.text "error"
    t.integer "error_event", limit: 2
    t.index ["active_job_id", "created_at"], name: "index_good_job_executions_on_active_job_id_and_created_at"
  end

  create_table "good_job_processes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "state"
  end

  create_table "good_job_settings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "key"
    t.jsonb "value"
    t.index ["key"], name: "index_good_job_settings_on_key", unique: true
  end

  create_table "good_jobs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "queue_name"
    t.integer "priority"
    t.jsonb "serialized_params"
    t.datetime "scheduled_at"
    t.datetime "performed_at"
    t.datetime "finished_at"
    t.text "error"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "active_job_id"
    t.text "concurrency_key"
    t.text "cron_key"
    t.uuid "retried_good_job_id"
    t.datetime "cron_at"
    t.uuid "batch_id"
    t.uuid "batch_callback_id"
    t.boolean "is_discrete"
    t.integer "executions_count"
    t.text "job_class"
    t.integer "error_event", limit: 2
    t.index ["active_job_id", "created_at"], name: "index_good_jobs_on_active_job_id_and_created_at"
    t.index ["active_job_id"], name: "index_good_jobs_on_active_job_id"
    t.index ["batch_callback_id"], name: "index_good_jobs_on_batch_callback_id", where: "(batch_callback_id IS NOT NULL)"
    t.index ["batch_id"], name: "index_good_jobs_on_batch_id", where: "(batch_id IS NOT NULL)"
    t.index ["concurrency_key"], name: "index_good_jobs_on_concurrency_key_when_unfinished", where: "(finished_at IS NULL)"
    t.index ["cron_key", "created_at"], name: "index_good_jobs_on_cron_key_and_created_at"
    t.index ["cron_key", "cron_at"], name: "index_good_jobs_on_cron_key_and_cron_at", unique: true
    t.index ["finished_at"], name: "index_good_jobs_jobs_on_finished_at", where: "((retried_good_job_id IS NULL) AND (finished_at IS NOT NULL))"
    t.index ["priority", "created_at"], name: "index_good_jobs_jobs_on_priority_created_at_when_unfinished", order: { priority: "DESC NULLS LAST" }, where: "(finished_at IS NULL)"
    t.index ["queue_name", "scheduled_at"], name: "index_good_jobs_on_queue_name_and_scheduled_at", where: "(finished_at IS NULL)"
    t.index ["scheduled_at"], name: "index_good_jobs_on_scheduled_at", where: "(finished_at IS NULL)"
  end

  create_table "log_events", force: :cascade do |t|
    t.text "loggable_type", null: false
    t.integer "loggable_id", null: false
    t.jsonb "payload", null: false
    t.datetime "created_at", null: false
    t.integer "action", null: false
    t.index ["loggable_id"], name: "index_log_events_on_loggable_id"
    t.index ["loggable_type", "loggable_id"], name: "index_log_events_on_loggable_type_and_loggable_id"
    t.index ["loggable_type"], name: "index_log_events_on_loggable_type"
  end

  create_table "submission_files", force: :cascade do |t|
    t.bigint "artist_submission_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "direct_url", null: false
    t.datetime "created_at_on_site", null: false
    t.text "file_identifier", null: false
    t.integer "width", null: false
    t.integer "height", null: false
    t.integer "size", null: false
    t.text "content_type", null: false
    t.timestamp "added_to_backlog_at"
    t.binary "iqdb_hash"
    t.timestamp "hidden_from_search_at"
    t.string "file_error"
    t.index ["artist_submission_id", "file_identifier"], name: "index_submission_files_on_artist_submission_id_and_file_id", unique: true
    t.index ["artist_submission_id"], name: "index_submission_files_on_artist_submission_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "artist_submissions", "artist_urls"
  add_foreign_key "artist_urls", "artists"
  add_foreign_key "e6_posts", "submission_files"
  add_foreign_key "submission_files", "artist_submissions"
end

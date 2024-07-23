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

ActiveRecord::Schema[7.1].define(version: 2024_07_23_190815) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "game_users", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "game_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "winner", default: false
    t.index ["game_id", "user_id"], name: "index_game_users_on_game_id_and_user_id", unique: true
    t.index ["game_id"], name: "index_game_users_on_game_id"
    t.index ["user_id"], name: "index_game_users_on_user_id"
  end

  create_table "games", force: :cascade do |t|
    t.string "name", null: false
    t.integer "required_number_players", default: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "go_fish"
    t.datetime "started_at"
    t.datetime "finished_at"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "game_users", "games"
  add_foreign_key "game_users", "users"

  create_view "leaderboards", sql_definition: <<-SQL
      SELECT users.id AS user_id,
      users.email,
      COALESCE(joined_subquery.total_games_joined, (0)::bigint) AS total_games_joined,
      COALESCE(completed_subquery.total_games_completed, (0)::bigint) AS total_games_completed,
      COALESCE(total_time_subquery.total_time_played, (0)::numeric) AS total_time_played,
      COALESCE(wins_subquery.wins, (0)::bigint) AS wins,
      COALESCE(losses_subquery.losses, (0)::bigint) AS losses,
      COALESCE(win_ratio_subquery.win_ratio, (0)::numeric) AS win_ratio
     FROM ((((((users
       LEFT JOIN ( SELECT users_1.email,
              users_1.id AS user_id,
              count(*) AS total_games_joined
             FROM (users users_1
               JOIN game_users ON ((game_users.user_id = users_1.id)))
            GROUP BY users_1.id) joined_subquery ON ((users.id = joined_subquery.user_id)))
       LEFT JOIN ( SELECT users_1.email,
              users_1.id AS user_id,
              count(*) AS total_games_completed
             FROM ((users users_1
               JOIN game_users ON ((game_users.user_id = users_1.id)))
               JOIN games ON ((games.id = game_users.game_id)))
            WHERE (games.finished_at IS NOT NULL)
            GROUP BY users_1.id) completed_subquery ON ((users.id = completed_subquery.user_id)))
       LEFT JOIN ( SELECT users_1.email,
              users_1.id AS user_id,
              sum(
                  CASE
                      WHEN (game_users.winner = true) THEN 1
                      ELSE 0
                  END) AS wins
             FROM ((users users_1
               JOIN game_users ON ((game_users.user_id = users_1.id)))
               JOIN games ON ((games.id = game_users.game_id)))
            WHERE (games.finished_at IS NOT NULL)
            GROUP BY users_1.id) wins_subquery ON ((users.id = wins_subquery.user_id)))
       LEFT JOIN ( SELECT users_1.email,
              users_1.id AS user_id,
              sum(
                  CASE
                      WHEN (game_users.winner = false) THEN 1
                      ELSE 0
                  END) AS losses
             FROM ((users users_1
               JOIN game_users ON ((game_users.user_id = users_1.id)))
               JOIN games ON ((games.id = game_users.game_id)))
            WHERE (games.finished_at IS NOT NULL)
            GROUP BY users_1.id) losses_subquery ON ((users.id = losses_subquery.user_id)))
       LEFT JOIN ( SELECT users_1.email,
              users_1.id AS user_id,
              sum(GREATEST(COALESCE(EXTRACT(epoch FROM (games.updated_at - games.started_at)), (0)::numeric), COALESCE(EXTRACT(epoch FROM (games.finished_at - games.started_at)), (0)::numeric))) AS total_time_played
             FROM ((users users_1
               JOIN game_users ON ((game_users.user_id = users_1.id)))
               JOIN games ON ((games.id = game_users.game_id)))
            GROUP BY users_1.id, users_1.email) total_time_subquery ON ((users.id = total_time_subquery.user_id)))
       LEFT JOIN ( SELECT users_1.email,
              users_1.id AS user_id,
              count(*) AS total_games_completed,
              sum(
                  CASE
                      WHEN (game_users.winner = true) THEN 1
                      ELSE 0
                  END) AS wins,
              round((((sum(
                  CASE
                      WHEN (game_users.winner = true) THEN 1
                      ELSE 0
                  END))::numeric / (count(*))::numeric) * (100)::numeric), 2) AS win_ratio
             FROM ((users users_1
               JOIN game_users ON ((game_users.user_id = users_1.id)))
               JOIN games ON ((games.id = game_users.game_id)))
            WHERE (games.finished_at IS NOT NULL)
            GROUP BY users_1.id, users_1.email) win_ratio_subquery ON ((users.id = win_ratio_subquery.user_id)))
    ORDER BY COALESCE(win_ratio_subquery.win_ratio, (0)::numeric) DESC;
  SQL
end

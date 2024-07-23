SELECT users.id AS user_id, users.email,
	COALESCE(joined_subquery.total_games_joined, 0) AS total_games_joined,
	COALESCE(completed_subquery.total_games_completed, 0) AS total_games_completed,
	COALESCE(total_time_subquery.total_time_played, 0) AS total_time_played,
	COALESCE(wins_subquery.wins, 0) AS wins,
	COALESCE(losses_subquery.losses, 0) AS losses,
	COALESCE(win_ratio_subquery.win_ratio, 0) AS win_ratio
FROM users
LEFT JOIN(
	SELECT users.email, users.id AS user_id, COUNT(*) AS total_games_joined
		FROM users
		INNER JOIN game_users ON game_users.user_id = users.id
		GROUP BY users.id
) AS joined_subquery ON users.id = joined_subquery.user_id
LEFT JOIN(
	SELECT users.email, users.id AS user_id, COUNT(*) AS total_games_completed
		FROM users
		INNER JOIN game_users ON game_users.user_id = users.id
		INNER JOIN games ON games.id = game_users.game_id
		WHERE games.finished_at IS NOT NULL
		GROUP BY users.id
) AS completed_subquery ON users.id = completed_subquery.user_id
LEFT JOIN(
	SELECT users.email, users.id AS user_id, SUM(CASE WHEN game_users.winner = TRUE THEN 1 ELSE 0 END) AS wins
		FROM users
		INNER JOIN game_users ON game_users.user_id = users.id
		INNER JOIN games ON games.id = game_users.game_id
		WHERE games.finished_at IS NOT NULL
		GROUP BY users.id
) AS wins_subquery ON users.id = wins_subquery.user_id
LEFT JOIN (
	SELECT users.email, users.id AS user_id, SUM(CASE WHEN game_users.winner = FALSE THEN 1 ELSE 0 END) AS losses
		FROM users
		INNER JOIN game_users ON game_users.user_id = users.id
		INNER JOIN games ON games.id = game_users.game_id
		WHERE games.finished_at IS NOT NULL
		GROUP BY users.id
) AS losses_subquery ON users.id = losses_subquery.user_id
LEFT JOIN (
	SELECT users.email, users.id AS user_id,
	  SUM(
	    GREATEST(
	      COALESCE(EXTRACT(EPOCH FROM (games.updated_at - games.started_at)), 0),
	      COALESCE(EXTRACT(EPOCH FROM (games.finished_at - games.started_at)), 0)
	    )
	  ) AS total_time_played
	FROM users
	INNER JOIN game_users ON game_users.user_id = users.id
	INNER JOIN games ON games.id = game_users.game_id
	GROUP BY users.id, users.email
) AS total_time_subquery ON users.id = total_time_subquery.user_id
LEFT JOIN (
	SELECT users.email, users.id AS user_id, COUNT(*) AS total_games_completed,
		SUM(CASE WHEN game_users.winner = TRUE THEN 1 ELSE 0 END) AS wins,
		ROUND(
			(SUM(CASE WHEN game_users.winner = TRUE THEN 1 ELSE 0 END)::decimal / COUNT(*)) * 100, 2
		) AS win_ratio
	FROM users
	INNER JOIN game_users ON game_users.user_id = users.id
	INNER JOIN games ON games.id = game_users.game_id
	WHERE games.finished_at IS NOT NULL
	GROUP BY users.id, users.email
) AS win_ratio_subquery ON users.id = win_ratio_subquery.user_id
ORDER BY win_ratio DESC;
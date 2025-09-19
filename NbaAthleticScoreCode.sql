CREATE VIEW player_combine_clean AS
SELECT
    draft_combine_stats.player_id,
    common_player_info.display_first_last,
    draft_combine_stats.position,
    draft_combine_stats.height_w_shoes AS height_in,
    draft_combine_stats.wingspan,
    draft_combine_stats.standing_vertical_leap AS vertical_leap,
    draft_combine_stats.bench_press AS bench_reps,
    draft_combine_stats.lane_agility_time AS agility_time,
    draft_combine_stats.spot_nba_top_key AS sprint_time
FROM draft_combine_stats
JOIN common_player_info
    ON draft_combine_stats.player_id = common_player_info.person_id;
   
CREATE VIEW player_combine_draft AS
SELECT
    player_combine_clean.player_id,
    player_combine_clean.display_first_last,
    player_combine_clean.position,
    player_combine_clean.height_in,
    player_combine_clean.wingspan,
    player_combine_clean.vertical_leap,
    player_combine_clean.bench_reps,
    player_combine_clean.agility_time,
    player_combine_clean.sprint_time,
    draft_history.season AS draft_season,
    draft_history.round_number AS draft_round,
    draft_history.overall_pick,
    draft_history.team_name AS drafted_team
FROM player_combine_clean
LEFT JOIN draft_history
    ON player_combine_clean.player_id = draft_history.person_id;

CREATE VIEW player_full_career AS
SELECT
    player_combine_draft.player_id,
    player_combine_draft.display_first_last,
    player_combine_draft.position,
    player_combine_draft.height_in,
    player_combine_draft.wingspan,
    player_combine_draft.vertical_leap,
    player_combine_draft.bench_reps,
    player_combine_draft.agility_time,
    player_combine_draft.sprint_time,
    player_combine_draft.draft_season,
    player_combine_draft.draft_round,
    player_combine_draft.overall_pick,
    player_combine_draft.drafted_team,
    common_player_info.from_year,
    common_player_info.to_year,
    (common_player_info.to_year - common_player_info.from_year + 1) AS career_length_years,
    common_player_info.games_played_flag
FROM player_combine_draft
LEFT JOIN common_player_info
    ON player_combine_draft.player_id = common_player_info.person_id;


SELECT
    draft_round,
    COUNT(player_id) AS num_players,
    AVG(height_in) AS avg_height,
    AVG(wingspan) AS avg_wingspan,
    AVG(vertical_leap) AS avg_vertical,
    AVG(bench_reps) AS avg_bench,
    AVG(agility_time) AS avg_agility,
    AVG(sprint_time) AS avg_sprint
FROM player_full_career
WHERE draft_round IS NOT NULL
GROUP BY draft_round
ORDER BY draft_round;

SELECT
    draft_round,
    COUNT(player_id) AS num_players,
    AVG(career_length_years) AS avg_career_length
FROM player_full_career
WHERE draft_round IS NOT NULL
GROUP BY draft_round
ORDER BY draft_round;

SELECT
    CASE
        WHEN height_in <= 76 THEN 'Guard'
        WHEN height_in BETWEEN 77 AND 81 THEN 'Wing'
        ELSE 'Big'
    END AS position_group,
    COUNT(player_id) AS num_players,
    AVG(career_length_years) AS avg_career_length,
    AVG(overall_pick) AS avg_draft_pick
FROM player_full_career
WHERE overall_pick IS NOT NULL
GROUP BY position_group;

SELECT
    draft_round,
    COUNT(player_id) AS num_players,
    AVG(career_length_years) AS avg_career_length,
    MIN(career_length_years) AS min_career_length,
    MAX(career_length_years) AS max_career_length
FROM player_full_career
WHERE draft_round IS NOT NULL
GROUP BY draft_round
ORDER BY draft_round;


CREATE VIEW player_athletic_score AS
WITH base AS (
  SELECT
    player_full_career.player_id,
    player_full_career.display_first_last,
    player_full_career.position,
    CAST(player_full_career.height_in AS REAL)      AS height_in,
    CAST(player_full_career.wingspan AS REAL)       AS wingspan,
    CAST(player_full_career.vertical_leap AS REAL)   AS vertical_leap,
    CAST(player_full_career.bench_reps AS REAL)      AS bench_reps,
    CAST(player_full_career.agility_time AS REAL)    AS agility_time,
    CAST(player_full_career.sprint_time AS REAL)     AS sprint_time,
    CAST(player_full_career.career_length_years AS REAL) AS career_length_years,
    (CAST(player_full_career.wingspan AS REAL) / NULLIF(CAST(player_full_career.height_in AS REAL),0.0)) AS wingspan_ratio
  FROM player_full_career
  WHERE player_full_career.height_in IS NOT NULL
    AND player_full_career.wingspan IS NOT NULL
    AND player_full_career.vertical_leap IS NOT NULL
    AND player_full_career.bench_reps IS NOT NULL
    AND player_full_career.agility_time IS NOT NULL
    AND player_full_career.sprint_time IS NOT NULL
),
stats AS (
  SELECT
    AVG(height_in) AS avg_height,
    AVG(wingspan_ratio) AS avg_wingspan_ratio,
    AVG(vertical_leap) AS avg_vertical,
    AVG(bench_reps) AS avg_bench,
    AVG(agility_time) AS avg_agility,
    AVG(sprint_time) AS avg_sprint,
    AVG(height_in*height_in) AS avg_height_sq,
    AVG(wingspan_ratio*wingspan_ratio) AS avg_wingspan_ratio_sq,
    AVG(vertical_leap*vertical_leap) AS avg_vertical_sq,
    AVG(bench_reps*bench_reps) AS avg_bench_sq,
    AVG(agility_time*agility_time) AS avg_agility_sq,
    AVG(sprint_time*sprint_time) AS avg_sprint_sq
  FROM base
),
z AS (
  SELECT
    base.*,
    CASE WHEN (stats.avg_height_sq - stats.avg_height*stats.avg_height) > 0
         THEN (base.height_in - stats.avg_height) / sqrt(stats.avg_height_sq - stats.avg_height*stats.avg_height)
         ELSE 0 END AS z_height,
    CASE WHEN (stats.avg_wingspan_ratio_sq - stats.avg_wingspan_ratio*stats.avg_wingspan_ratio) > 0
         THEN (base.wingspan_ratio - stats.avg_wingspan_ratio) / sqrt(stats.avg_wingspan_ratio_sq - stats.avg_wingspan_ratio*stats.avg_wingspan_ratio)
         ELSE 0 END AS z_wingspan_ratio,
    CASE WHEN (stats.avg_vertical_sq - stats.avg_vertical*stats.avg_vertical) > 0
         THEN (base.vertical_leap - stats.avg_vertical) / sqrt(stats.avg_vertical_sq - stats.avg_vertical*stats.avg_vertical)
         ELSE 0 END AS z_vertical,
    CASE WHEN (stats.avg_bench_sq - stats.avg_bench*stats.avg_bench) > 0
         THEN (base.bench_reps - stats.avg_bench) / sqrt(stats.avg_bench_sq - stats.avg_bench*stats.avg_bench)
         ELSE 0 END AS z_bench,
    -- invert times so lower = better (higher z)
    CASE WHEN (stats.avg_agility_sq - stats.avg_agility*stats.avg_agility) > 0
         THEN (stats.avg_agility - base.agility_time) / sqrt(stats.avg_agility_sq - stats.avg_agility*stats.avg_agility)
         ELSE 0 END AS z_agility,
    CASE WHEN (stats.avg_sprint_sq - stats.avg_sprint*stats.avg_sprint) > 0
         THEN (stats.avg_sprint - base.sprint_time) / sqrt(stats.avg_sprint_sq - stats.avg_sprint*stats.avg_sprint)
         ELSE 0 END AS z_sprint
  FROM base CROSS JOIN stats
)
SELECT
  player_id,
  display_first_last,
  position,
  height_in,
  wingspan,
  wingspan_ratio,
  vertical_leap,
  bench_reps,
  agility_time,
  sprint_time,
  career_length_years,
  z_height,
  z_wingspan_ratio,
  z_vertical,
  z_bench,
  z_agility,
  z_sprint,
  -- average of the 6 z-scores (equal weight)
  (z_height + z_wingspan_ratio + z_vertical + z_bench + z_agility + z_sprint) / 6.0 AS athletic_score
FROM z;


SELECT player_id, display_first_last, position, athletic_score, career_length_years
FROM player_athletic_score
ORDER BY athletic_score DESC



-- write your code in PostgreSQL 9.4
WITH new as (
    SELECT DISTINCT match_id, host_team, guest_team,
        CASE
            WHEN host_goals > guest_goals THEN 3
            WHEN host_goals = guest_goals THEN 1
            WHEN host_goals < guest_goals THEN 0
        END AS host_score,
        CASE
            WHEN guest_goals > host_goals THEN 3
            WHEN guest_goals = host_goals THEN 1
            WHEN guest_goals < host_goals THEN 0
        END AS guest_score
    FROM matches),
guestscore as (
    SELECT guest_team as teams,SUM(guest_score) as score
    FROM new
    GROUP BY guest_team),
hostscore as (
    SELECT host_team as teams,SUM(host_score) as score
    FROM new
    GROUP BY host_team),
combine as (
    SELECT * FROM guestscore
    UNION ALL SELECT * FROM hostscore),
combined as (
    SELECT teams, SUM(score) as score
    FROM combine
    GROUP BY teams),
overall as (
    SELECT * FROM teams
    LEFT JOIN combined
    ON teams.team_id = combined.teams)

SELECT team_id,team_name,
    CASE
        WHEN score is NULL THEN 0
        ELSE score
    END AS num_point
FROM overall
ORDER BY num_point DESC,team_id ASC

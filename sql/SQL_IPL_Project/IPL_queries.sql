use IPL;


-- ─────────────────────────────────────────────────────────────
-- Q1. Total number of deliveries in the dataset
-- ─────────────────────────────────────────────────────────────
SELECT COUNT(*) AS total_deliveries
FROM deliveries;

-- ─────────────────────────────────────────────────────────────
-- Q2. Total runs scored across all IPL matches
-- ─────────────────────────────────────────────────────────────
SELECT SUM(total_runs) AS total_runs_scored
FROM deliveries;


-- ─────────────────────────────────────────────────────────────
-- Q3. Top 10 run-scorers of all time
-- ─────────────────────────────────────────────────────────────
SELECT batter,
       SUM(batsman_runs) AS total_runs
FROM deliveries
GROUP BY batter
ORDER BY total_runs DESC
LIMIT 10;


-- ─────────────────────────────────────────────────────────────
-- Q4. Top 10 wicket-takers (excluding run-outs)
-- ─────────────────────────────────────────────────────────────
SELECT bowler,
       COUNT(*) AS wickets
FROM deliveries
WHERE is_wicket = 1
  AND dismissal_kind NOT IN ('run out', 'retired hurt', 'obstructing the field')
GROUP BY bowler
ORDER BY wickets DESC
LIMIT 10;


-- ─────────────────────────────────────────────────────────────
-- Q5. Teams with most sixes hit
-- ─────────────────────────────────────────────────────────────
SELECT batting_team,
       COUNT(*) AS sixes
FROM deliveries
WHERE batsman_runs = 6
GROUP BY batting_team
ORDER BY sixes DESC;


-- ─────────────────────────────────────────────────────────────
-- Q6. Teams with most fours hit
-- ─────────────────────────────────────────────────────────────
SELECT batting_team,
       COUNT(*) AS fours
FROM deliveries
WHERE batsman_runs = 4
GROUP BY batting_team
ORDER BY fours DESC;


-- ─────────────────────────────────────────────────────────────
-- Q7. Most extras conceded by a bowling team (Top 10)
-- ─────────────────────────────────────────────────────────────
SELECT bowling_team,
       SUM(extra_runs) AS total_extras
FROM deliveries
GROUP BY bowling_team
ORDER BY total_extras DESC
LIMIT 10;


-- ─────────────────────────────────────────────────────────────
-- Q8. Average runs scored per over across all matches
-- ─────────────────────────────────────────────────────────────
SELECT ROUND(AVG(over_num), 2) AS avg_runs_per_over
FROM (
    SELECT match_id, over_num, SUM(total_runs) AS over_runs
    FROM deliveries d
    GROUP BY match_id, over_num
) AS over_totals;


-- ─────────────────────────────────────────────────────────────
-- Q9. Total wickets fallen in IPL history
-- ─────────────────────────────────────────────────────────────
SELECT COUNT(*) AS total_wickets
FROM deliveries
WHERE is_wicket = 1;


-- ─────────────────────────────────────────────────────────────
-- Q10. Most common dismissal types
-- ─────────────────────────────────────────────────────────────
SELECT dismissal_kind,
       COUNT(*) AS occurrences
FROM deliveries
WHERE is_wicket = 1
GROUP BY dismissal_kind
ORDER BY occurrences DESC;


-- ─────────────────────────────────────────────────────────────
-- Q11. Batter with most sixes — Top 10
-- ─────────────────────────────────────────────────────────────
SELECT batter,
       COUNT(*) AS sixes
FROM deliveries
WHERE batsman_runs = 6
GROUP BY batter
ORDER BY sixes DESC
LIMIT 10;


-- ─────────────────────────────────────────────────────────────
-- Q12. Batters with highest strike rate (minimum 500 balls faced)
-- ─────────────────────────────────────────────────────────────
SELECT batter,
       COUNT(*) AS balls_faced,
       SUM(batsman_runs) AS runs,
       ROUND(SUM(batsman_runs) * 100.0 / COUNT(*), 2) AS strike_rate
FROM deliveries
GROUP BY batter
HAVING balls_faced >= 500
ORDER BY strike_rate DESC
LIMIT 10;


-- ─────────────────────────────────────────────────────────────
-- Q13. Bowlers with best economy rate (minimum 300 balls bowled)
-- ─────────────────────────────────────────────────────────────
SELECT bowler,
       COUNT(*)                                   AS balls_bowled,
       ROUND(SUM(total_runs) * 6.0 / COUNT(*), 2) AS economy_rate
FROM deliveries
GROUP BY bowler
HAVING balls_bowled >= 300
ORDER BY economy_rate ASC
LIMIT 10;


-- ─────────────────────────────────────────────────────────────
-- Q14. Highest team score in a single inning
-- ─────────────────────────────────────────────────────────────
SELECT match_id,
       batting_team,
       inning,
       SUM(total_runs) AS score
FROM deliveries
GROUP BY match_id, batting_team, inning
ORDER BY score DESC
LIMIT 5;


-- ─────────────────────────────────────────────────────────────
-- Q15. Total number of unique matches played
-- ─────────────────────────────────────────────────────────────
SELECT COUNT(DISTINCT match_id) AS total_matches
FROM deliveries;


-- ─────────────────────────────────────────────────────────────
-- Q16. Runs scored in 1st inning vs 2nd inning (overall)
-- ─────────────────────────────────────────────────────────────
SELECT inning,
       SUM(total_runs) AS total_runs
FROM deliveries
WHERE inning IN (1, 2)
GROUP BY inning;


-- ─────────────────────────────────────────────────────────────
-- Q17. No-balls bowled per team
-- ─────────────────────────────────────────────────────────────
SELECT bowling_team,
       COUNT(*) AS no_balls
FROM deliveries
WHERE extras_type = 'noballs'
GROUP BY bowling_team
ORDER BY no_balls DESC;


-- ─────────────────────────────────────────────────────────────
-- Q18. Wides bowled per team
-- ─────────────────────────────────────────────────────────────
SELECT bowling_team,
       COUNT(*) AS wides
FROM deliveries
WHERE extras_type = 'wides'
GROUP BY bowling_team
ORDER BY wides DESC;


-- ─────────────────────────────────────────────────────────────
-- Q19. Most matches played by each franchise
-- ─────────────────────────────────────────────────────────────
SELECT batting_team,
       COUNT(DISTINCT match_id) AS matches_played
FROM deliveries
GROUP BY batting_team
ORDER BY matches_played DESC
LIMIT 10;


-- ─────────────────────────────────────────────────────────────
-- Q20. Batters with most dot balls faced — Top 10
-- ─────────────────────────────────────────────────────────────
SELECT batter,
       COUNT(*) AS dot_balls
FROM deliveries
WHERE batsman_runs = 0
  AND extra_runs   = 0
GROUP BY batter
ORDER BY dot_balls DESC
LIMIT 10;


-- ─────────────────────────────────────────────────────────────
-- Q21. Bowlers with most dot balls bowled — Top 10
-- ─────────────────────────────────────────────────────────────
SELECT bowler,
       COUNT(*) AS dot_balls
FROM deliveries
WHERE total_runs = 0
GROUP BY bowler
ORDER BY dot_balls DESC
LIMIT 10;


-- ─────────────────────────────────────────────────────────────
-- Q22. Total batting runs per team across all seasons
-- ─────────────────────────────────────────────────────────────
SELECT batting_team,
       SUM(batsman_runs) AS total_batting_runs
FROM deliveries
GROUP BY batting_team
ORDER BY total_batting_runs DESC;


-- ─────────────────────────────────────────────────────────────
-- Q23. Highest individual score in a single innings — Top 10
-- ─────────────────────────────────────────────────────────────
SELECT match_id,
       inning,
       batter,
       SUM(batsman_runs) AS runs_scored
FROM deliveries
GROUP BY match_id, inning, batter
ORDER BY runs_scored DESC
LIMIT 10;


-- ─────────────────────────────────────────────────────────────
-- Q24. Top 10 most productive batting partnerships in a match
-- ─────────────────────────────────────────────────────────────
SELECT match_id,
       inning,
       batter,
       non_striker,
       SUM(total_runs) AS partnership_runs
FROM deliveries
GROUP BY match_id, inning, batter, non_striker
ORDER BY partnership_runs DESC
LIMIT 10;


-- ─────────────────────────────────────────────────────────────
-- Q25. How many times each team batted first (inning 1)
-- ─────────────────────────────────────────────────────────────
SELECT batting_team,
       COUNT(DISTINCT match_id) AS times_batted_first
FROM deliveries
WHERE inning = 1
GROUP BY batting_team
ORDER BY times_batted_first DESC;


-- ─────────────────────────────────────────────────────────────
-- Q26. Average runs per over-number (1–20) — powerplay vs death
-- ─────────────────────────────────────────────────────────────
SELECT (over_num + 1)          AS over_number,
       ROUND(AVG(over_runs), 2) AS avg_runs
FROM (
    SELECT match_id, inning, over_num,
           SUM(total_runs) AS over_runs
    FROM deliveries
    GROUP BY match_id, inning, over_num
) AS over_totals
GROUP BY over_num
ORDER BY over_number;


-- ─────────────────────────────────────────────────────────────
-- Q27. Batters involved in most run-outs — Top 10
-- ─────────────────────────────────────────────────────────────
SELECT player_dismissed,
       COUNT(*) AS run_outs
FROM deliveries
WHERE dismissal_kind = 'run out'
GROUP BY player_dismissed
ORDER BY run_outs DESC
LIMIT 10;


-- ─────────────────────────────────────────────────────────────
-- Q28. Highest-scoring matches (combined runs, both teams) — Top 5
-- ─────────────────────────────────────────────────────────────
SELECT match_id,
       SUM(total_runs) AS combined_runs
FROM deliveries
GROUP BY match_id
ORDER BY combined_runs DESC
LIMIT 5;


-- ─────────────────────────────────────────────────────────────
-- Q29. Bowlers who took 5-wicket hauls (fifers)
-- ─────────────────────────────────────────────────────────────
SELECT match_id,
       inning,
       bowler,
       COUNT(*) AS wickets
FROM deliveries
WHERE is_wicket = 1
  AND dismissal_kind NOT IN ('run out', 'retired hurt')
GROUP BY match_id, inning, bowler
HAVING wickets >= 5
ORDER BY wickets DESC;


-- ─────────────────────────────────────────────────────────────
-- Q30. Team-wise breakdown: runs, wickets, sixes, fours
--      (Full team scorecard summary)
-- ─────────────────────────────────────────────────────────────
SELECT batting_team,
       SUM(batsman_runs)                              AS total_runs,
       SUM(is_wicket)                                 AS wickets_lost,
       SUM(CASE WHEN batsman_runs = 6 THEN 1 ELSE 0 END) AS sixes,
       SUM(CASE WHEN batsman_runs = 4 THEN 1 ELSE 0 END) AS fours,
       COUNT(DISTINCT match_id)                       AS matches_played
FROM deliveries
GROUP BY batting_team
ORDER BY total_runs DESC;

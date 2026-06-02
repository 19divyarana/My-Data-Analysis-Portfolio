-- ===============================
-- BASIC QUERIES (1–10)
-- ===============================

-- 1. Total number of matches
SELECT COUNT(*) FROM matches;

-- 2. Total number of seasons
SELECT COUNT(DISTINCT season) FROM matches;

-- 3. List all unique teams
SELECT DISTINCT team1 FROM matches
UNION
SELECT DISTINCT team2 FROM matches;

-- 4. Matches won by each team
SELECT winner, COUNT(*) AS wins
FROM matches
GROUP BY winner;

-- 5. Matches per season
SELECT season, COUNT(*) AS total_matches
FROM matches
GROUP BY season;

-- 6. Player of match awards count
SELECT player_of_match, COUNT(*) AS awards
FROM matches
GROUP BY player_of_match
ORDER BY awards DESC;

-- 7. Matches played in each city
SELECT city, COUNT(*) AS matches
FROM matches
GROUP BY city;

-- 8. Maximum win by runs
SELECT MAX(win_by_runs) FROM matches;

-- 9. Matches won batting first
SELECT COUNT(*) 
FROM matches
WHERE win_by_runs > 0;

-- 10. Matches won batting second
SELECT COUNT(*) 
FROM matches
WHERE win_by_wickets > 0;


-- ===============================
-- INTERMEDIATE (11–20)
-- ===============================

-- 11. Total runs scored in IPL
SELECT SUM(total_runs) FROM deliveries;

-- 12. Top 10 batsmen by runs
SELECT batter, SUM(batsman_runs) AS total_runs
FROM deliveries
GROUP BY batter
ORDER BY total_runs DESC
LIMIT 10;

-- 13. Total wickets taken
SELECT COUNT(*) 
FROM deliveries
WHERE is_wicket = 1;

-- 14. Top 10 bowlers by wickets
SELECT bowler, COUNT(*) AS wickets
FROM deliveries
WHERE is_wicket = 1
GROUP BY bowler
ORDER BY wickets DESC
LIMIT 10;

-- 15. Total extra runs
SELECT SUM(extra_runs) FROM deliveries;

-- 16. Strike rate of batsmen
SELECT batter,
       SUM(batsman_runs) * 100.0 / COUNT(*) AS strike_rate
FROM deliveries
GROUP BY batter
HAVING COUNT(*) > 100;

-- 17. Economy rate of bowlers
SELECT bowler,
       SUM(total_runs) / (COUNT(*)/6.0) AS economy
FROM deliveries
GROUP BY bowler;

-- 18. Matches where toss winner won match
SELECT COUNT(*) 
FROM matches
WHERE toss_winner = winner;

-- 19. Average runs per match
SELECT AVG(match_runs)
FROM (
    SELECT match_id, SUM(total_runs) AS match_runs
    FROM deliveries
    GROUP BY match_id
) t;

-- 20. Highest scoring match
SELECT match_id, SUM(total_runs) AS total_runs
FROM deliveries
GROUP BY match_id
ORDER BY total_runs DESC
LIMIT 1;


-- ===============================
-- ADVANCED (21–30)
-- ===============================

-- 21. Total runs by each team
SELECT batting_team, SUM(total_runs) AS runs
FROM deliveries
GROUP BY batting_team;

-- 22. Total sixes in IPL
SELECT COUNT(*) 
FROM deliveries
WHERE batsman_runs = 6;

-- 23. Total fours in IPL
SELECT COUNT(*) 
FROM deliveries
WHERE batsman_runs = 4;

-- 24. Top batsmen by sixes
SELECT batter, COUNT(*) AS sixes
FROM deliveries
WHERE batsman_runs = 6
GROUP BY batter
ORDER BY sixes DESC;

-- 25. Top batsmen by fours
SELECT batter, COUNT(*) AS fours
FROM deliveries
WHERE batsman_runs = 4
GROUP BY batter
ORDER BY fours DESC;

-- 26. Runs scored in powerplay (overs 1–6)
SELECT SUM(total_runs)
FROM deliveries
WHERE over_no <= 6;

-- 27. Runs scored in death overs (16–20)
SELECT SUM(total_runs)
FROM deliveries
WHERE over_no >= 16;

-- 28. Dot balls count
SELECT COUNT(*) 
FROM deliveries
WHERE total_runs = 0;

-- 29. Highest individual score (per match)
SELECT batter, match_id, SUM(batsman_runs) AS score
FROM deliveries
GROUP BY batter, match_id
ORDER BY score DESC
LIMIT 1;

-- 30. Toss decision analysis
SELECT toss_decision,
       COUNT(*) AS matches,
       SUM(CASE WHEN winner = toss_winner THEN 1 ELSE 0 END) AS wins
FROM matches
GROUP BY toss_decision;

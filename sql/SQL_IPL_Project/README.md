## IPL SQL Analysis Project

> A beginner-to-intermediate **MySQL** project using the IPL ball-by-ball deliveries dataset.  
> 30 real analytical queries covering simple aggregations to subqueries and CASE WHEN logic.

## Project Structure

ipl_sql_project/
├── ipl_schema.sql          ← Run ONCE — creates DB, table & inserts all data
├── ipl_queries.sql         ← All 30 queries with answers in comments
└── README.md               ← This file

##  Dataset Overview

| Column              | Type         | Description                                       |
|---------------------|--------------|---------------------------------------------------|
| `match_id`          | INT          | Unique match identifier                           |
| `inning`            | TINYINT      | Inning number (1 or 2)                            |
| `batting_team`      | VARCHAR(60)  | Team currently batting                            |
| `bowling_team`      | VARCHAR(60)  | Team currently bowling                            |
| `over_num`          | TINYINT      | Over number (0-indexed, so 0 = Over 1)            |
| `ball`              | TINYINT      | Ball number within the over                       |
| `batter`            | VARCHAR(60)  | Batter facing the delivery                        |
| `bowler`            | VARCHAR(60)  | Bowler delivering the ball                        |
| `non_striker`       | VARCHAR(60)  | Batter at non-striker end                         |
| `batsman_runs`      | TINYINT      | Runs scored by the batter off this ball           |
| `extra_runs`        | TINYINT      | Extra runs (wides, no-balls, byes, leg-byes)      |
| `total_runs`        | TINYINT      | Total runs off this delivery (batsman + extras)   |
| `extras_type`       | VARCHAR(20)  | Type of extra: wides / noballs / byes / legbyes   |
| `is_wicket`         | TINYINT      | 1 if a wicket fell, 0 otherwise                   |
| `player_dismissed`  | VARCHAR(60)  | Name of dismissed player (NULL if no wicket)      |
| `dismissal_kind`    | VARCHAR(40)  | How the player was dismissed                      |
| `fielder`           | VARCHAR(60)  | Fielder involved in dismissal (if applicable)     |


## 💡 SQL Concepts Covered

- `SELECT`, `FROM`, `WHERE`, `GROUP BY`, `ORDER BY`, `LIMIT`
- Aggregate functions: `COUNT`, `SUM`, `AVG`, `ROUND`
- Filtering groups with `HAVING`
- Subqueries (inline views with `AS alias`)
- `CASE WHEN` expressions
- `COUNT(DISTINCT ...)` for unique counts
- `NOT IN` for exclusion filters

---

##  Key Insights from the Data

| Insight                            |  Value                                |
|----------------------------------- |---------------------------------------|
|  All-time top scorer               | **V Kohli** — 8,014 runs              |
|  All-time top wicket-taker         | **YS Chahal** — 205 wickets           |
|  Most sixes by a batter            | **CH Gayle** — 359 sixes              |
|  Highest team innings              | **SRH 287** (Match 1426268)           |
|  Highest individual innings        | **CH Gayle 175\*** (Match 598027)     |
|  Best strike rate (500+ balls)     | **AD Russell** — 164.22               |
|  Best economy (300+ balls)         | **A Kumble** — 6.65                   |
|  Highest-scoring match             | **Match 1426268** — 549 combined runs |
|  Total matches in dataset          | **1,095**                             |
|  Total wickets                     | **12,950**                            |

---

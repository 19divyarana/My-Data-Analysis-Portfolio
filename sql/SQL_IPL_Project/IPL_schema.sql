create database IPL;

use IPL;

SHOW VARIABLES LIKE 'local_infile';

SET GLOBAL local_infile = 1;

DROP TABLE IF EXISTS deliveries;

CREATE TABLE deliveries (
    match_id           INT,
    inning             TINYINT,
    batting_team       VARCHAR(60),
    bowling_team       VARCHAR(60),
    over_num           TINYINT,
    ball               TINYINT,
    batter             VARCHAR(60),
    bowler             VARCHAR(60),
    non_striker        VARCHAR(60),
    batsman_runs       TINYINT,
    extra_runs         TINYINT,
    total_runs         TINYINT,
    extras_type        VARCHAR(20),
    is_wicket          TINYINT,
    player_dismissed   VARCHAR(60),
    dismissal_kind     VARCHAR(40),
    fielder            VARCHAR(60)
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/deliveries.csv'
INTO TABLE deliveries
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

desc deliveries;

select*from deliveries;


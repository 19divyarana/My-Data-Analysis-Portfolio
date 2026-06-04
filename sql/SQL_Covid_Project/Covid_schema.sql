use Covid;

CREATE TABLE IF NOT EXISTS covid_data (
    record_id           INTEGER        PRIMARY KEY,
    date                DATE           NOT NULL,
    country             VARCHAR(50)    NOT NULL,
    continent           VARCHAR(30)    NOT NULL,
    population          BIGINT         NOT NULL,
    new_cases           INT            NOT NULL DEFAULT 0,
    cumulative_cases    BIGINT         NOT NULL DEFAULT 0,
    new_deaths          INT            NOT NULL DEFAULT 0,
    cumulative_deaths   BIGINT         NOT NULL DEFAULT 0,
    active_cases        BIGINT         NOT NULL DEFAULT 0,
    new_recoveries      INT            NOT NULL DEFAULT 0,
    vaccinations_total  BIGINT         NOT NULL DEFAULT 0,
    pct_vaccinated      DECIMAL(7,4)   NOT NULL DEFAULT 0,
    case_fatality_rate  DECIMAL(7,4)   NOT NULL DEFAULT 0
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/covid_data.csv'
INTO TABLE covid_data
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

desc covid_data;
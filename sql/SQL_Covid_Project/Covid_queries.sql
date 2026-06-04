-- ─────────────────────────────────────────────────────────
-- Q1: Global Totals — Cases, Deaths, Recoveries, Vaccinations
--     The single-number executive summary of the pandemic
-- ─────────────────────────────────────────────────────────
SELECT
    COUNT(DISTINCT country)  AS countries_tracked,
    SUM(new_cases) AS total_cases,
    SUM(new_deaths) AS total_deaths,
    SUM(new_recoveries) AS total_recoveries,
    ROUND(SUM(new_deaths) * 100.0 / NULLIF(SUM(new_cases), 0), 3) AS global_cfr_pct,
    MAX(vaccinations_total)  AS max_vaccinations_single_country
FROM covid_data;

-- ─────────────────────────────────────────────────────────
-- Q2: Country-Level Summary — Full Pandemic Scorecard
--     Ranks all countries by total case burden
-- ─────────────────────────────────────────────────────────
SELECT
    country,
    continent,
    population,
    MAX(cumulative_cases) AS total_cases,
    MAX(cumulative_deaths) AS total_deaths,
    ROUND(MAX(cumulative_cases)  * 100.0 / population, 2)  AS infection_rate_pct,
    ROUND(MAX(cumulative_deaths) * 100.0
          / NULLIF(MAX(cumulative_cases), 0), 3) AS cfr_pct,
    MAX(vaccinations_total) AS total_vaccinated,
    ROUND(MAX(pct_vaccinated), 2) AS max_vax_pct,
    RANK() OVER (ORDER BY MAX(cumulative_cases) DESC) AS case_rank
FROM covid_data
GROUP BY country, continent, population
ORDER BY total_cases DESC;

-- ─────────────────────────────────────────────────────────
-- Q3: Continent-Level Aggregation
--     Which continents were hardest hit overall?
-- ─────────────────────────────────────────────────────────
SELECT
    continent,
    COUNT(DISTINCT country) AS countries,
    SUM(new_cases) AS total_cases,
    SUM(new_deaths) AS total_deaths,
    ROUND(SUM(new_deaths) * 100.0 / NULLIF(SUM(new_cases), 0), 3) AS cfr_pct,
    ROUND(SUM(new_cases) * 1.0  / COUNT(DISTINCT country), 0) AS avg_cases_per_country,
    ROUND(SUM(new_deaths) * 1.0 / COUNT(DISTINCT country), 0) AS avg_deaths_per_country
FROM covid_data
GROUP BY continent
ORDER BY total_cases DESC;

-- ─────────────────────────────────────────────────────────
-- Q4: Deaths per Million Population (Normalised Mortality)
--     Fair comparison across countries of different sizes
-- ─────────────────────────────────────────────────────────
SELECT
    country,
    population,
    MAX(cumulative_deaths) AS total_deaths,
    ROUND(MAX(cumulative_deaths) * 1000000.0 / population, 2) AS deaths_per_million,
    ROUND(MAX(cumulative_cases)  * 1000000.0 / population, 2) AS cases_per_million,
    RANK() OVER (ORDER BY MAX(cumulative_deaths) * 1000000.0 / population DESC)
AS mortality_rank
FROM covid_data
GROUP BY country, population
ORDER BY deaths_per_million DESC;

-- ─────────────────────────────────────────────────────────
-- Q5: Daily Global Case and Death Totals (All Countries Combined)
--     Tracks the overall pandemic curve day by day
-- ─────────────────────────────────────────────────────────
SELECT
    date,
    SUM(new_cases) AS global_new_cases,
    SUM(new_deaths) AS global_new_deaths,
    SUM(active_cases) AS global_active_cases,
    SUM(new_recoveries) AS global_recoveries
FROM covid_data
GROUP BY date
ORDER BY date;


-- ╔══════════════════════════════════════════════════════════╗
-- ║         SECTION 2: TREND & WAVE ANALYSIS (Q6–Q12)       ║
-- ╚══════════════════════════════════════════════════════════╝

-- ─────────────────────────────────────────────────────────
-- Q6: 7-Day Rolling Average of New Cases per Country
--     Smooths daily noise to reveal underlying trends
-- ─────────────────────────────────────────────────────────
SELECT
    date,
    country,
    new_cases,
    ROUND(AVG(new_cases) OVER (
        PARTITION BY country
        ORDER BY date
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ), 0) AS rolling_7day_avg_cases,
    ROUND(AVG(new_deaths) OVER (
        PARTITION BY country
        ORDER BY date
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ), 0) AS rolling_7day_avg_deaths
FROM covid_data
WHERE date >= '2020-03-01'
ORDER BY country, date;

-- ─────────────────────────────────────────────────────────
-- Q7: Peak Daily Cases per Country
--     Identifies the single worst day of the pandemic per nation
-- ─────────────────────────────────────────────────────────
SELECT
    country,
    date AS peak_date,
    new_cases AS peak_daily_cases,
    new_deaths AS deaths_on_peak_day,
    active_cases AS active_on_peak_day,
    cumulative_cases AS cumulative_at_peak,
    ROUND(pct_vaccinated, 2) AS vax_pct_at_peak
FROM (
    SELECT *,
           RANK() OVER (PARTITION BY country ORDER BY new_cases DESC) AS rk
    FROM covid_data
) ranked
WHERE rk = 1
ORDER BY peak_daily_cases DESC;

-- ─────────────────────────────────────────────────────────
-- Q8: Monthly New Cases and Deaths by Country
--     Monthly granularity to track wave timing
-- ─────────────────────────────────────────────────────────
SELECT
    country,
    DATEDIFF('%Y', date)  AS year,
    DATEDIFF('%m', date)  AS month,
    SUM(new_cases) AS monthly_cases,
    SUM(new_deaths) AS monthly_deaths,
    SUM(new_recoveries) AS monthly_recoveries,
    ROUND(SUM(new_deaths) * 100.0 / NULLIF(SUM(new_cases), 0), 3) AS monthly_cfr
FROM covid_data
GROUP BY country, year, month
ORDER BY country, year, month;

-- ─────────────────────────────────────────────────────────
-- Q9: Quarter-over-Quarter Case Growth per Country
--     Measures acceleration or deceleration of the virus
-- ─────────────────────────────────────────────────────────
WITH quarterly AS (
    SELECT
        country,
        YEAR(date) AS yr,
        QUARTER(date) AS qtr,
        SUM(new_cases) AS qtr_cases,
        SUM(new_deaths) AS qtr_deaths
    FROM covid_data
    GROUP BY country, YEAR(date), QUARTER(date)
)
SELECT
    country,
    yr,
    qtr,
    qtr_cases,
    qtr_deaths,
    LAG(qtr_cases) OVER (
        PARTITION BY country
        ORDER BY yr, qtr
    ) AS prev_qtr_cases,
    ROUND(
        (
            qtr_cases -
            LAG(qtr_cases) OVER (
                PARTITION BY country
                ORDER BY yr, qtr
            )
        ) * 100.0 /
        NULLIF(
            LAG(qtr_cases) OVER (
                PARTITION BY country
                ORDER BY yr, qtr
            ),
            0
        ),
        2
    ) AS qoq_growth_pct
FROM quarterly
ORDER BY country, yr, qtr;

-- ─────────────────────────────────────────────────────────
-- Q10: Wave Detection — Classify Each Day's Intensity
--      Labels each record as Major Wave / Surge / Baseline
-- ─────────────────────────────────────────────────────────
WITH country_peak AS (
    SELECT country, MAX(new_cases) AS peak_cases
    FROM covid_data
    GROUP BY country
)
SELECT
    c.date,
    c.country,
    c.new_cases,
    p.peak_cases,
    ROUND(c.new_cases * 100.0 / NULLIF(p.peak_cases, 0), 1) AS pct_of_peak,
    CASE
        WHEN c.new_cases >= p.peak_cases * 0.6 THEN 'Major Wave'
        WHEN c.new_cases >= p.peak_cases * 0.3 THEN 'Moderate Surge'
        WHEN c.new_cases >= p.peak_cases * 0.1 THEN 'Low Activity'
        ELSE 'Baseline'
    END AS wave_status
FROM covid_data c
JOIN country_peak p USING (country)
ORDER BY c.country, c.date;

-- ─────────────────────────────────────────────────────────
-- Q11: Longest Consecutive Days Above 10,000 New Cases
--      Measures sustained outbreak duration per country
-- ─────────────────────────────────────────────────────────
WITH flagged AS (
    SELECT date, country, new_cases,
           CASE WHEN new_cases >= 10000 THEN 1 ELSE 0 END AS above_threshold
    FROM covid_data
),
grouped AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY country ORDER BY date) -
           ROW_NUMBER() OVER (PARTITION BY country, above_threshold ORDER BY date) AS grp
    FROM flagged
)
SELECT
    country,
    MIN(date)             AS streak_start,
    MAX(date)             AS streak_end,
    COUNT(*)              AS consecutive_days,
    SUM(new_cases)        AS total_cases_in_streak
FROM grouped
WHERE above_threshold = 1
GROUP BY country, grp
ORDER BY consecutive_days DESC
LIMIT 20;

-- ─────────────────────────────────────────────────────────
-- Q12: Year-over-Year Comparison 2020 vs 2021
--      How did each country's burden shift between years?
-- ─────────────────────────────────────────────────────────
SELECT
    country,
    SUM(CASE WHEN DATEDIFF('%Y', date) = '2020' THEN new_cases  ELSE 0 END) AS cases_2020,
    SUM(CASE WHEN DATEDIFF('%Y', date) = '2021' THEN new_cases  ELSE 0 END) AS cases_2021,
    SUM(CASE WHEN DATEDIFF('%Y', date) = '2020' THEN new_deaths ELSE 0 END) AS deaths_2020,
    SUM(CASE WHEN DATEDIFF('%Y', date) = '2021' THEN new_deaths ELSE 0 END) AS deaths_2021,
    ROUND(
        (SUM(CASE WHEN DATEDIFF('%Y', date) = '2021' THEN new_cases ELSE 0 END)
       - SUM(CASE WHEN DATEDIFF('%Y', date) = '2020' THEN new_cases ELSE 0 END))
        * 100.0 / NULLIF(SUM(CASE WHEN DATEDIFF('%Y', date) = '2020' THEN new_cases ELSE 0 END), 0)
    , 2) AS yoy_case_change_pct
FROM covid_data
GROUP BY country
ORDER BY yoy_case_change_pct DESC;


-- ╔══════════════════════════════════════════════════════════╗
-- ║       SECTION 3: MORTALITY & SEVERITY ANALYSIS (Q13–Q18)║
-- ╚══════════════════════════════════════════════════════════╝

-- ─────────────────────────────────────────────────────────
-- Q13: Case Fatality Rate Trend Over Time per Country
--      Tracks whether CFR improved as treatment evolved
-- ─────────────────────────────────────────────────────────
SELECT
    country,
    DATE_FORMAT(date, '%Y-%m') AS month,
    ROUND(AVG(case_fatality_rate), 3) AS avg_monthly_cfr,
    MAX(case_fatality_rate) AS peak_monthly_cfr,
    MIN(case_fatality_rate) AS min_monthly_cfr
FROM covid_data
WHERE cumulative_cases > 0
GROUP BY country, DATE_FORMAT(date, '%Y-%m')
ORDER BY country, month;

-- ─────────────────────────────────────────────────────────
-- Q14: CFR Before vs After Vaccine Rollout (Jan 2021)
--      Quantifies the vaccine's impact on mortality rate
-- ─────────────────────────────────────────────────────────
SELECT
    country,
    ROUND(AVG(CASE WHEN date < '2021-01-01'  THEN case_fatality_rate END), 3) AS cfr_pre_vaccine,
    ROUND(AVG(CASE WHEN date >= '2021-01-01' THEN case_fatality_rate END), 3) AS cfr_post_vaccine,
    ROUND(
        AVG(CASE WHEN date < '2021-01-01'  THEN case_fatality_rate END)
      - AVG(CASE WHEN date >= '2021-01-01' THEN case_fatality_rate END)
    , 3) AS cfr_improvement,
    CASE
        WHEN AVG(CASE WHEN date < '2021-01-01' THEN case_fatality_rate END)
           > AVG(CASE WHEN date >= '2021-01-01' THEN case_fatality_rate END)
        THEN 'Improved'
        ELSE 'No Improvement'
    END AS verdict
FROM covid_data
GROUP BY country
ORDER BY cfr_improvement DESC;

-- ─────────────────────────────────────────────────────────
-- Q15: Days with Highest Deaths (Top 20 Globally)
--      Identifies the deadliest single days across all countries
-- ─────────────────────────────────────────────────────────
SELECT
    date,
    country,
    new_deaths,
    new_cases,
    ROUND(new_deaths * 100.0 / NULLIF(new_cases, 0), 2) AS daily_cfr_pct,
    cumulative_deaths,
    ROUND(pct_vaccinated, 2) AS vax_pct_on_day
FROM covid_data
ORDER BY new_deaths DESC
LIMIT 20;

-- ─────────────────────────────────────────────────────────
-- Q16: Active Case Load — Monthly Average per Country
--      Shows healthcare system pressure over time
-- ─────────────────────────────────────────────────────────
SELECT
    country,
    DATEDIFF('%Y-%m', date) month,
    ROUND(AVG(active_cases), 0)          AS avg_active_cases,
    MAX(active_cases)                    AS peak_active_cases,
    ROUND(AVG(active_cases) * 100.0 / population, 4) AS active_pct_of_pop
FROM covid_data
GROUP BY country,month, population
ORDER BY country,month;

-- ─────────────────────────────────────────────────────────
-- Q17: Recovery Rate Analysis per Country
--      Proportion of cases that recovered vs died
-- ─────────────────────────────────────────────────────────
SELECT
    country,
    MAX(cumulative_cases) AS total_cases,
    MAX(cumulative_deaths) AS total_deaths,
    SUM(new_recoveries) AS total_recoveries,
    ROUND(SUM(new_recoveries) * 100.0
          / NULLIF(MAX(cumulative_cases), 0), 2) AS recovery_rate_pct,
    ROUND(MAX(cumulative_deaths) * 100.0
          / NULLIF(MAX(cumulative_cases), 0), 3) AS death_rate_pct,
    ROUND((MAX(cumulative_cases) - MAX(cumulative_deaths) - SUM(new_recoveries))
          * 100.0 / NULLIF(MAX(cumulative_cases), 0), 2) AS unresolved_pct
FROM covid_data
GROUP BY country
ORDER BY recovery_rate_pct DESC;

-- ─────────────────────────────────────────────────────────
-- Q18: Countries with Death Counts Above Global Average
--      Identifies outlier mortality nations
-- ─────────────────────────────────────────────────────────
WITH country_deaths AS (
    SELECT country, MAX(cumulative_deaths) AS total_deaths
    FROM covid_data
    GROUP BY country
),
global_avg AS (
    SELECT AVG(total_deaths) AS avg_deaths FROM country_deaths
)
SELECT
    cd.country,
    cd.total_deaths,
    ga.avg_deaths,
    ROUND(cd.total_deaths - ga.avg_deaths, 0) AS above_avg_by,
    ROUND(cd.total_deaths * 100.0 / ga.avg_deaths, 1) AS pct_of_avg
FROM country_deaths cd, global_avg ga
WHERE cd.total_deaths > ga.avg_deaths
ORDER BY cd.total_deaths DESC;


-- ╔══════════════════════════════════════════════════════════╗
-- ║      SECTION 4: VACCINATION ANALYSIS (Q19–Q24)          ║
-- ╚══════════════════════════════════════════════════════════╝

-- ─────────────────────────────────────────────────────────
-- Q19: Vaccination Rollout Timeline per Country
--      Tracks when each coverage milestone was reached
-- ─────────────────────────────────────────────────────────
SELECT
    country,
    MIN(CASE WHEN pct_vaccinated >= 1  THEN date END) AS reached_1pct,
    MIN(CASE WHEN pct_vaccinated >= 10 THEN date END) AS reached_10pct,
    MIN(CASE WHEN pct_vaccinated >= 25 THEN date END) AS reached_25pct,
    MIN(CASE WHEN pct_vaccinated >= 50 THEN date END) AS reached_50pct,
    MIN(CASE WHEN pct_vaccinated >= 75 THEN date END) AS reached_75pct,
    MAX(ROUND(pct_vaccinated, 2)) AS final_coverage_pct
FROM covid_data
GROUP BY country
ORDER BY
    reached_50pct IS NULL,
    reached_50pct;

-- ─────────────────────────────────────────────────────────
-- Q20: Speed of Vaccination — Days from 10% to 50% Coverage
--      Identifies which countries rolled out fastest
-- ─────────────────────────────────────────────────────────
WITH milestones AS (
    SELECT
        country,
        MIN(CASE WHEN pct_vaccinated >= 10 THEN date END) AS date_10pct,
        MIN(CASE WHEN pct_vaccinated >= 50 THEN date END) AS date_50pct
    FROM covid_data
    GROUP BY country
)
SELECT
    country,
    date_10pct,
    date_50pct,
    DATEDIFF(date_50pct, date_10pct) AS days_to_scale,
    RANK() OVER (
        ORDER BY DATEDIFF(date_50pct, date_10pct)
    ) AS speed_rank
FROM milestones
WHERE date_10pct IS NOT NULL
  AND date_50pct IS NOT NULL
ORDER BY days_to_scale;

-- ─────────────────────────────────────────────────────────
-- Q21: Monthly Vaccination Progress per Country
--      Month-by-month doses administered and coverage gained
-- ─────────────────────────────────────────────────────────
WITH monthly_vaccination AS (
    SELECT
        country,
        DATE_FORMAT(date, '%Y-%m') AS month,
        MAX(vaccinations_total) AS cumulative_vaccinated,
        ROUND(MAX(pct_vaccinated), 2) AS coverage_pct
    FROM covid_data
    GROUP BY country, DATE_FORMAT(date, '%Y-%m')
)
SELECT
    country,
    month,
    cumulative_vaccinated,
    cumulative_vaccinated -
        COALESCE(
            LAG(cumulative_vaccinated) OVER (
                PARTITION BY country
                ORDER BY month
            ),
            0
        ) AS new_doses_this_month,
    coverage_pct
FROM monthly_vaccination
ORDER BY country,month;

-- ─────────────────────────────────────────────────────────
-- Q22: Vaccination Coverage vs Active Cases (Post-Rollout)
--      Does higher vaccination correlate with lower active cases?
-- ─────────────────────────────────────────────────────────
SELECT
    country,
    DATE_FORMAT(date, '%Y-%m') AS month,
    ROUND(AVG(pct_vaccinated), 2) AS avg_vax_pct,
    ROUND(AVG(active_cases), 0) AS avg_active_cases,
    ROUND(AVG(new_cases), 0) AS avg_new_cases,
    ROUND(AVG(new_deaths), 1) AS avg_new_deaths,
    CASE
        WHEN AVG(pct_vaccinated) >= 50 THEN 'High Coverage (50%+)'
        WHEN AVG(pct_vaccinated) >= 25 THEN 'Medium Coverage (25-50%)'
        WHEN AVG(pct_vaccinated) > 0 THEN 'Early Rollout (<25%)'
        ELSE 'Pre-Vaccine'
    END AS coverage_band
FROM covid_data
GROUP BY
    country,
    DATE_FORMAT(date, '%Y-%m')
ORDER BY
    country,month;

-- ─────────────────────────────────────────────────────────
-- Q23: Population vs Total Vaccinated (Absolute Gap)
--      How far each country is from full population coverage
-- ─────────────────────────────────────────────────────────
SELECT
    country,
    population,
    MAX(vaccinations_total) AS total_vaccinated,
    population - MAX(vaccinations_total)  AS unvaccinated_count,
    ROUND(MAX(pct_vaccinated), 2) AS coverage_pct,
    ROUND((population - MAX(vaccinations_total)) * 100.0 / population, 2) AS unvaccinated_pct
FROM covid_data
GROUP BY country, population
ORDER BY unvaccinated_count DESC;

-- ─────────────────────────────────────────────────────────
-- Q24: Avg New Cases in High-Vax vs Low-Vax Months
--      Aggregate comparison of pandemic intensity by coverage band
-- ─────────────────────────────────────────────────────────
SELECT
    CASE
        WHEN pct_vaccinated >= 50 THEN 'High (50%+)'
        WHEN pct_vaccinated >= 25 THEN 'Medium (25-49%)'
        WHEN pct_vaccinated >  0  THEN 'Low (1-24%)'
        ELSE 'None (0%)'
    END  AS vax_band,
    COUNT(*) AS record_count,
    ROUND(AVG(new_cases), 0) AS avg_new_cases,
    ROUND(AVG(new_deaths), 1) AS avg_new_deaths,
    ROUND(AVG(case_fatality_rate), 3) AS avg_cfr,
    ROUND(AVG(active_cases), 0) AS avg_active_cases
FROM covid_data
GROUP BY vax_band
ORDER BY avg_new_cases DESC;


-- ╔══════════════════════════════════════════════════════════╗
-- ║     SECTION 5: ADVANCED & COMPARATIVE QUERIES (Q25–Q30) ║
-- ╚══════════════════════════════════════════════════════════╝

-- ─────────────────────────────────────────────────────────
-- Q25: Running Cumulative Cases with % of Final Total
--      Shows what fraction of all cases had occurred by each date
-- ─────────────────────────────────────────────────────────
WITH country_total AS (
    SELECT country, MAX(cumulative_cases) AS grand_total
    FROM covid_data GROUP BY country
)
SELECT
    c.date,
    c.country,
    c.cumulative_cases,
    ct.grand_total,
    ROUND(c.cumulative_cases * 100.0 / ct.grand_total, 2) AS pct_of_final_total
FROM covid_data c
JOIN country_total ct USING (country)
ORDER BY c.country, c.date;

-- ─────────────────────────────────────────────────────────
-- Q26: Which Country Had the Fastest Doubling of Cases?
--      Measures exponential growth speed in early pandemic
-- ─────────────────────────────────────────────────────────
WITH milestones AS (
    SELECT
        country,
        MIN(CASE WHEN cumulative_cases >= 100 THEN date END) AS date_100_cases,
        MIN(CASE WHEN cumulative_cases >= 200 THEN date END) AS date_200_cases
    FROM covid_data
    GROUP BY country
)
SELECT
    country,
    date_100_cases,
    date_200_cases,
    DATEDIFF(date_200_cases, date_100_cases) AS days_to_double,
    RANK() OVER (
        ORDER BY DATEDIFF(date_200_cases, date_100_cases)
    ) AS fastest_rank
FROM milestones
WHERE date_100_cases IS NOT NULL
  AND date_200_cases IS NOT NULL
ORDER BY days_to_double;

-- ─────────────────────────────────────────────────────────
-- Q27: Worst 30-Day Window per Country (Most New Cases)
--      Identifies the hardest single month of the pandemic
-- ─────────────────────────────────────────────────────────
WITH rolling_30 AS (
    SELECT
        date,
        country,
        SUM(new_cases) OVER (
            PARTITION BY country
            ORDER BY date
            ROWS BETWEEN 29 PRECEDING AND CURRENT ROW
        ) AS cases_last_30_days,
        SUM(new_deaths) OVER (
            PARTITION BY country
            ORDER BY date
            ROWS BETWEEN 29 PRECEDING AND CURRENT ROW
        ) AS deaths_last_30_days
    FROM covid_data
),
ranked AS (
    SELECT *,
           RANK() OVER (PARTITION BY country ORDER BY cases_last_30_days DESC) AS rk
    FROM rolling_30
)
SELECT
    country,
    date AS window_end_date,
    cases_last_30_days  AS worst_30day_cases,
    deaths_last_30_days AS worst_30day_deaths
FROM ranked
WHERE rk = 1
ORDER BY worst_30day_cases DESC;

-- ─────────────────────────────────────────────────────────
-- Q28: Correlation Proxy — New Cases vs New Deaths (30-day lag)
--      Deaths lag cases; this shows the 30-day lagged death signal
-- ─────────────────────────────────────────────────────────
WITH lagged AS (
    SELECT
        date,
        country,
        new_deaths,
        LAG(new_cases, 30) OVER (PARTITION BY country ORDER BY date) AS cases_30_days_ago
    FROM covid_data
)
SELECT
    date,
    country,
    new_deaths,
    cases_30_days_ago,
    ROUND(new_deaths * 1.0 / NULLIF(cases_30_days_ago, 0) * 100, 3) AS implied_cfr_30day_lag
FROM lagged
WHERE cases_30_days_ago IS NOT NULL
  AND cases_30_days_ago > 0
ORDER BY country, date;

-- ─────────────────────────────────────────────────────────
-- Q29: Country Pandemic Phases Summary
--      Categorises each country's pandemic into 3 key phases
-- ─────────────────────────────────────────────────────────
SELECT
    country,
    -- Phase 1: Pre-vaccine (2020)
    SUM(CASE WHEN date BETWEEN '2020-01-01' AND '2020-06-30'
             THEN new_cases ELSE 0 END)  AS phase1_cases_H1_2020,
    SUM(CASE WHEN date BETWEEN '2020-07-01' AND '2020-12-31'
             THEN new_cases ELSE 0 END)  AS phase2_cases_H2_2020,
    -- Phase 3: Vaccine rollout era
    SUM(CASE WHEN date BETWEEN '2021-01-01' AND '2021-06-30'
             THEN new_cases ELSE 0 END)  AS phase3_cases_H1_2021,
    SUM(CASE WHEN date BETWEEN '2021-07-01' AND '2021-12-31'
             THEN new_cases ELSE 0 END)  AS phase4_cases_H2_2021,
    -- Deaths by phase
    SUM(CASE WHEN date <= '2020-12-31' THEN new_deaths ELSE 0 END) AS deaths_2020,
    SUM(CASE WHEN date >= '2021-01-01' THEN new_deaths ELSE 0 END) AS deaths_2021
FROM covid_data
GROUP BY country
ORDER BY (phase3_cases_H1_2021 + phase4_cases_H2_2021) DESC;

-- ─────────────────────────────────────────────────────────
-- Q30: Executive Dashboard — One-Row KPIs per Country
--      A comprehensive single-query summary of the full dataset
-- ─────────────────────────────────────────────────────────
SELECT
    country,
    continent,
    population,
    MAX(cumulative_cases) AS total_cases,
    MAX(cumulative_deaths) AS total_deaths,
    SUM(new_recoveries) AS total_recoveries,
    ROUND(MAX(cumulative_cases) * 100.0 / population, 2) AS infection_rate_pct,
    ROUND(MAX(cumulative_deaths) * 100.0
          / NULLIF(MAX(cumulative_cases), 0), 3) AS overall_cfr_pct,
    ROUND(SUM(new_recoveries) * 100.0
          / NULLIF(MAX(cumulative_cases), 0), 2) AS recovery_rate_pct,
    MAX(vaccinations_total) AS vaccinated,
    ROUND(MAX(pct_vaccinated), 1) AS vax_coverage_pct,
    MAX(new_cases) AS peak_single_day_cases,
    MAX(new_deaths) AS peak_single_day_deaths,
    MIN(CASE WHEN pct_vaccinated >= 50 THEN date END) AS date_50pct_vax,
    ROUND(AVG(CASE WHEN date < '2021-01-01' THEN case_fatality_rate END), 3) AS cfr_2020,
    ROUND(AVG(CASE WHEN date >= '2021-01-01' THEN case_fatality_rate END), 3) AS cfr_2021
FROM covid_data
GROUP BY country, continent, population
ORDER BY total_cases DESC;

## COVID-19 SQL Analysis Project

> **30 analytical SQL queries on a daily COVID-19 dataset covering 10 countries across 2020–2021, with insights on case trends, mortality, wave detection, and vaccination impact.**

##  Dataset Overview

**Source:** Synthetically generated from documented COVID-19 epidemiological patterns (2020–2021), seeded for reproducibility (`seed=42`).

| Column | Type | Description |
|--------|------|-------------|
| `record_id` | INTEGER | Unique row identifier |
| `date` | DATE | Daily date (2020-01-01 → 2021-12-31) |
| `country` | TEXT | Country name |
| `continent` | TEXT | Geographic continent |
| `population` | INTEGER | Country population |
| `new_cases` | INTEGER | Daily new confirmed cases |
| `cumulative_cases` | INTEGER | Running total cases |
| `new_deaths` | INTEGER | Daily new deaths |
| `cumulative_deaths` | INTEGER | Running total deaths |
| `active_cases` | INTEGER | Currently active cases |
| `new_recoveries` | INTEGER | Daily recoveries |
| `vaccinations_total` | INTEGER | Total doses administered |
| `pct_vaccinated` | REAL | % of population vaccinated |
| `case_fatality_rate` | REAL | Deaths / Cases × 100 |

**Countries:** USA, India, Brazil, UK, Germany, France, Italy, Spain, Canada, Australia  

### MySQL
```sql
LOAD DATA LOCAL INFILE 'data/covid_data.csv'
INTO TABLE covid_data FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
```

## Key Insights (From Actual Query Results)

### 1. Pandemic Scale — 620 Million Cases, 9.4 Million Deaths
Across 10 countries over two years: **620,714,556 total cases** and **9,387,915 deaths**, giving a global Case Fatality Rate of **1.512%** (Q1).

### 2. India Bore the Largest Absolute Burden
India recorded **371.8 million cases** — over 4× the USA's 89.5 million — purely due to population size. However, all 10 countries converged on a **~26–27% infection rate** of their population

### 3. USA Led Mortality When Population-Adjusted
Despite India's higher absolute deaths, the USA ranked #1 in **deaths per million at 4,150**, followed by Spain (4,084) and India (4,075). France had the lowest at 3,775.

### 4. India's Worst Day Dwarfed All Others
India's peak was **2,366,386 new cases on 2021-07-23** — nearly 4× the USA's peak of 660,589. Brazil's worst day was 493,915 (2021-03-21) during its severe Delta wave .

### 5. 2021 Was 2–3× Worse Than 2020 in Every Country
Every country saw 224–260% more cases in 2021 than 2020. France led with **+259% YoY growth**, Germany was lowest at **+224%**. The Delta and Omicron variants drove this acceleration.

### 6. Vaccination Rollout Was Remarkably Synchronised
All 10 countries reached **10% coverage around late January 2021** and **50% coverage in May–June 2021** — a window of just ~5 weeks across all nations. Italy was fastest to 50% (May 16), USA was last (June 1).

### 7. CFR Did Not Drop Dramatically After Vaccination
Pre-vaccine CFR (2020 avg): **~1.47–1.59%** | Post-vaccine CFR (2021 avg): **~1.46–1.53%**. The UK showed the largest improvement (1.587 → 1.533), while Spain slightly worsened. Vaccines primarily reduced hospitalisations and severe outcomes, not the confirmed-case death ratio.

### 8. High Vaccination Periods Still Had High Case Counts
Periods with 50%+ vaccination coverage averaged **143,382 new cases/day** vs 37,895 in pre-vaccine periods (Q24). This confirms vaccines reduce severity but don't eliminate transmission — especially with Delta/Omicron variants.

### 9. The Worst 30-Day Windows All Fell in 2021
 reveals every country's worst single 30-day case window occurred in 2021 (not 2020), despite widespread vaccination — driven by more transmissible variants overwhelming even partial immunity.

### 10. Deaths Lag Cases by ~30 Days
 lag analysis shows a strong implied CFR signal when new deaths are compared against cases from 30 days prior — confirming the well-documented incubation + deterioration timeline of COVID-19.

---

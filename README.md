# Data Modeling - Salary Survey

This project analyzes survey responses from software developers around the world, focusing on salary normalization, data quality, and model transparency. It is built in BigQuery using DBT and follows layered transformations for clarity and modularity.

## Project Goals

- Practice DBT with a semi-structured dataset
- Normalize salaries using inflation and GDP data
- Demonstrate professional data modeling and testing practices

## Data Sources

- `survey_data` – Raw survey data (CSV, ~16,000 rows)
- `seed__country_economic_factors` – Median/mean salary benchmarks by country
- `seed__inflation_factors` – Adjustment factors relative to 2024
- `seed__country_mapping` – 2-letter to full country name mapping

## DBT Layers

### Staging

Standardizes raw and seed inputs

### Intermediate

- Cleans, normalizes, and flags outliers in survey data  
- Aggregates country-level statistics

### Mart

- `mart_survey__base`: Final cleaned dataset  
- `mart_survey__aggregates`: Summary statistics

### Metrics & Snapshots

- Data quality metrics  
- Snapshot tracking of economic factors

## Key Features

- Contract enforcement and meta info on mart models
- Extensive testing: uniqueness, nulls, accepted values, logic
- GitHub Actions for CI with scheduled DBT runs
- Source freshness tracking
- Column descriptions from markdown
- Exposures and tags defined in the DAG

## Data Quality Checks

- Nulls and duplicates
- Invalid or inconsistent entries
- Outlier detection with modified Z-scores
- Soft duplicates (salary ±1% with identical attributes)

## Aggregates (Selected)

- Median and average salaries (normalized and raw)
- P25/P75, IQR, std dev, skewness indicators

## Future Work

- Integration of unit tests: [EqualExperts/dbt-unit-testing](https://github.com/EqualExperts/dbt-unit-testing)

## How to Run

- By simply pushing to your github repo, Github Actions kick into action and do the work.

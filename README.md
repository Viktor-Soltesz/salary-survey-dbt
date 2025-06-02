# salary-survey-dbt

## Modeling & Transformation (Stage 2 of 6)

This repository performs semantic modeling, normalization, data cleaning, and metric creation using **DBT** on data loaded into BigQuery.  
It transforms raw but structured survey data into reliable, analyzable models for downstream statistical analysis and business intelligence.  
Part of a modular data stack for analyzing global developer salary survey responses.

---

## Project Overview

This project is split into modular repositories, each handling one part of the full ELT and analytics pipeline:

| Stage | Name                        | Description                                | Repository |
|-------|-----------------------------|--------------------------------------------|------------|
| 1     | Ingestion & Infrastructure  | Terraform + Cloud Functions for ETL        | [salary-survey-iac](https://github.com/Viktor-Soltesz/salary-survey-iac) |
| 2     | **Modeling & Transformation**   | DBT models, metrics, testing            | **[salary-survey-dbt](https://github.com/Viktor-Soltesz/salary-survey-dbt)** |
| 3     | Business Intelligence       | Tableau dashboards                         | Tableau Public |
| 4     | Model Observability         | Drift & lineage (Elementary)               | [salary-survey-edr](https://github.com/Viktor-Soltesz/salary-survey-edr) |
| 5     | Data Quality Monitoring     | GX monitoring pre/post transform           | [salary-survey-gx](https://github.com/Viktor-Soltesz/salary-survey-gx) |
| 6     | Statistical Analysis        | ANOVA, regressions, prediction             | [salary-analysis](https://github.com/Viktor-Soltesz/salary-analysis) |

---

## Repository Scope

This repository refines the output of the ETL pipeline using **DBT**.  
It performs:
- Free-text standardization and classification
- Enrichment with external reference data
- Outlier detection and filtering
- Creation of semantic and aggregated data marts
- Column- and model-level testing and documentation
- Preparation of metrics for Tableau and statistical modeling

It ensures that downstream users receive clean, validated, and well-documented data for analysis and decision-making.

---

## Detailed Breakdown

### 1. DBT Structure

- **Staging layer**: Renames and retypes raw input, normalizes country and job fields
- **Intermediate layer**: Applies logic for outlier handling, free-text mapping, value coercion
- **Mart layer**:
  - `mart_cleaned`: fully transformed, row-level data
  - `mart_aggregated`: grouped by major factors for fast dashboard querying

---

### 2. Key Transformations

- Standardize and categorize:
  - Job titles, seniority levels, industries, company size
- Enrich with:
  - Inflation rates, GDP per capita, PPP adjustments
- Handle outliers:
  - Flag and remove salary entries based on z-scores, country-specific thresholds, and logical anomalies
- Create derived metrics:
  - USD-normalized salary, GDP-adjusted salary, ratios across categories

---

### 3. Data Testing & Validation

- Built-in `dbt` tests for:
  - Null checks
  - Accepted values
  - Uniqueness and referential integrity
- Custom tests for:
  - Outlier count
  - Uncategorizable responses
  - Soft duplicates
- Track data quality metrics:
  - Nulls, unexpected values, and transformation success rates

---

### 4. Documentation & Semantics

- Semantic layer defined with `dbt_metrics`
- All columns, tables, and tests described using `meta` tags
- `dbt docs` generated locally and hosted via GitHub Pages:
  - DAG graph
  - Test summaries
  - Table and column lineage

---

### 5. Scheduling & Alerts

- DBT is scheduled using GitHub Actions
- On each run:
  - Model runs + tests + metrics update
  - If failure or data drift occurs, a Slack alert is triggered

---

## Setup Instructions

1. Clone this repo and install `dbt` and required plugins
2. Set up a `profiles.yml` file with your BigQuery credentials
3. Run:
   ```bash
   dbt deps
   dbt seed
   dbt build
   dbt docs generate
   dbt docs serve

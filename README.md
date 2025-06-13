# salary-survey-dbt

## Modeling & Transformation (Stage 2 of 5)

This repository performs semantic modeling, normalization, data cleaning, and metric creation using **DBT** on data loaded into BigQuery.  
It transforms raw but structured survey data into reliable, analyzable models for downstream statistical analysis and business intelligence.  
Part of a modular data stack for analyzing global developer salary survey responses.

---

## Project Overview

This project is split into modular repositories, each handling one part of the full ELT and analytics pipeline:

| Stage | Name                        | Description                                | Link |
|-------|-----------------------------|--------------------------------------------|------------|
| ㅤ1     | Ingestion & Infrastructure  | Terraform + Python Cloud Functions        | [salary-survey-iac (GitHub)](https://github.com/Viktor-Soltesz/salary-survey-iac) |
| **▶️2** | **Data Transformation**   | **DBT data models and testing**               | **[salary-survey-dbt (GitHub)](https://github.com/Viktor-Soltesz/salary-survey-dbt) <br> ㅤ⤷ [DBT docs](https://viktor-soltesz.github.io/salary-survey-dbt-docs/index.html#!/overview)**|
| ㅤ3     | Data Observability  | Great Expectations & Elementary, <br> model monitoring and data observability     | [salary-survey-gx (GitHub)](https://github.com/Viktor-Soltesz/salary-survey-gx) <br> ㅤ⤷ [GX log](https://viktor-soltesz.github.io/salary-survey-gx/gx_site/index.html) <br> ㅤ⤷ [Elementary report](https://viktor-soltesz.github.io/salary-survey-dbt/elementary_report.html#/report/dashboard) |
| ㅤ4     | Statistical Modeling    | ANOVA, multiregressions, prediction   | [salary-survey-analysis (GitHub)](https://github.com/Viktor-Soltesz/salary-survey-analysis) |
| ㅤ5     | Dashboards          | •ㅤInteractive salary exploration <br> •ㅤData Health metrics, gathered during runs <br> •ㅤBilling report, live export from GCP <br> •ㅤBigQuery report, from GCP logging |ㅤ🡢 [Tableau Public](https://public.tableau.com/app/profile/viktor.solt.sz/viz/SoftwareDeveloperSalaries/Dashboard) <br>ㅤ🡢 [Looker Studio](https://lookerstudio.google.com/s/mhwL6JfNlaw)<br>ㅤ🡢 [Looker Studio](https://lookerstudio.google.com/s/tp8jUo4oPRs)<br>ㅤ🡢 [Looker Studio](https://lookerstudio.google.com/s/v2BIFW-_Jak)|
| ㅤ+     | Extra material | •ㅤPresentation <br> •ㅤData Dictionary <br>  •ㅤSLA Table <br>  •ㅤMy LinkedIn<br>  •ㅤMy CV|ㅤ🡢 [Google Slides](https://docs.google.com/presentation/d/1BHC6QnSpObVpulEcyDLXkW-6YLo2hpnwQ3miQg43iBg/edit?slide=id.g3353e8463a7_0_28#slide=id.g3353e8463a7_0_28) <br>ㅤ🡢 [Google Sheets](https://docs.google.com/spreadsheets/d/1cTikHNzcw3e-gH3N8F4VX-viYlCeLbm5JkFE3Wdcnjo/edit?gid=0#gid=0) <br>ㅤ🡢 [Google Sheets](https://docs.google.com/spreadsheets/d/1r85NlwsGV1DDy4eRBfMjZgI-1_uyIbl1fUazgY00Kz0/edit?usp=sharing) <br>ㅤ🡢 [LinkedIn](https://www.linkedin.com/in/viktor-soltesz/) <br>ㅤ🡢 [Google Docs](https://www.linkedin.com/in/viktor-soltesz/)|

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
  - `mart_survey__base`: fully transformed, row-level data
  - `mart_survey__aggregates`: grouped by major factors for fast dashboard querying
- **Metric layer**:
  - Tracking data health metrics. Later ingested by Looker dashboards.
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

1. Clone this repo.
2. Use GitHub's workflow dispatch.
3. Sit back, as GitHub Actions will do the rest.
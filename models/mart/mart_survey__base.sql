-- mart_survey.sql
{{ config(
    tags=['layer:mart', 'domain:survey'],
    materialized = 'table',
    contract={"enforced": true}
) }}

-- This model provides the final cleaned and normalized dataset of global developer salaries,
-- ready for consumption by dashboards, reporting, or analysis.
-- It excludes statistical outliers and selects only meaningful fields.

WITH source AS (
    SELECT *
    FROM {{ ref('int_survey_data__outliers_flagged') }}
    WHERE is_outlier = FALSE
)

SELECT
    -- IDs
    CAST(survey_entry_id AS STRING) AS survey_entry_id,
    CAST(entry_number AS INT64) AS entry_number,

    -- Time
    CAST(year AS INT64) AS year,

    -- Key dimensions
    CAST(country AS STRING) AS country,
    CAST(country_name AS STRING) AS country_name,
    CAST(job_category AS STRING) AS job_category,
    CAST(seniority_level AS STRING) AS seniority_level,
    CAST(employment_status AS STRING) AS employment_status,
    CAST(company_size AS STRING) AS company_size,

    -- Raw and normalized values
    CAST(salary AS NUMERIC) AS salary,
    CAST(salary_norm2024 AS NUMERIC) AS salary_norm2024,
    CAST(salary_normgdp AS NUMERIC) AS salary_normgdp,
    CAST(salary_norm AS NUMERIC) AS salary_norm,

    -- Enrichment fields
    CAST(gdp_ppp AS FLOAT64) AS gdp_ppp,
    CAST(factor_to_2024 AS NUMERIC) AS factor_to_2024,

    -- Outlier score (for reference only)
    CAST(z_score_modif AS NUMERIC) AS z_score_modif

FROM source

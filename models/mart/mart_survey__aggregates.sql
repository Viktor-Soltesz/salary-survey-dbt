-- mart_survey_aggregates.sql
{{ config(
    tags=['layer:mart', 'domain:survey'],
    materialized = 'table',
    contract={"enforced": true}
) }}

-- This model aggregates survey data by key dimensions, providing summary statistics
-- for normalized salary values.

SELECT
    -- Dimensions
    CAST(country AS STRING) AS country,
    CAST(country_name AS STRING) AS country_name,
    CAST(year AS INT64) AS year,
    CAST(seniority_level AS STRING) AS seniority_level,
    CAST(job_category AS STRING) AS job_category,
    CAST(company_size AS STRING) AS company_size,

    CAST(COUNT(*) AS INT64) AS entry_count,

    -- Measures of center
    CAST(APPROX_QUANTILES(salary_norm, 100)[OFFSET(50)] AS NUMERIC) AS median_salary_norm,
    CAST(APPROX_QUANTILES(salary_norm2024, 100)[OFFSET(50)] AS NUMERIC) AS median_salary_2024,
    CAST(APPROX_QUANTILES(salary_normgdp, 100)[OFFSET(50)] AS NUMERIC) AS median_salary_gdp,

    CAST(AVG(salary_norm) AS NUMERIC) AS avg_salary_norm,
    CAST(AVG(salary_norm2024) AS NUMERIC) AS avg_salary_2024,
    CAST(AVG(salary_normgdp) AS NUMERIC) AS avg_salary_gdp,

    -- Measures of spread
    CAST(APPROX_QUANTILES(salary_norm, 100)[OFFSET(25)] AS NUMERIC) AS p25_salary_norm,
    CAST(APPROX_QUANTILES(salary_norm, 100)[OFFSET(75)] AS NUMERIC) AS p75_salary_norm,
    CAST(STDDEV(salary_norm) AS FLOAT64) AS stddev_salary_norm, -- STDDEV often returns FLOAT64

    -- Interquartile Range and Skewness approximation (Calculations involving NUMERICs result in NUMERIC)
    CAST(
        APPROX_QUANTILES(salary_norm, 100)[OFFSET(75)] -
        APPROX_QUANTILES(salary_norm, 100)[OFFSET(25)]
        AS NUMERIC
    ) AS iqr_salary_norm,

    CAST(
        AVG(salary_norm) - APPROX_QUANTILES(salary_norm, 100)[OFFSET(50)]
        AS NUMERIC
    ) AS skewness_indicator

FROM {{ ref('int_survey_data__outliers_flagged') }}
WHERE is_outlier IS FALSE -- Assuming is_outlier exists in the referenced model
GROUP BY
    country,
    country_name,
    year,
    seniority_level,
    job_category,
    company_size
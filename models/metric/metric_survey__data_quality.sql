-- metric_survey__data_quality.sql
{{ config(
    tags=['layer:metric', 'domain:survey'],
    materialized = 'incremental',
    unique_key = 'run_date',
    contract={"enforced": false}
) }}

WITH base AS (
    SELECT *
    FROM {{ ref('stg_survey_data') }}
),
after_cleaning AS (
    SELECT *
    FROM {{ ref('int_survey_data__cleaned') }}
),
after_normalization AS (
    SELECT *
    FROM {{ ref('int_survey_data__outliers_flagged') }}
),
final_mart AS (
    SELECT *
    FROM {{ ref('mart_survey__base') }}
)

SELECT
    CURRENT_TIMESTAMP() AS run_date,
    COUNT(*) AS total_entries,
    -- Null checks from stg_survey_data
    COUNTIF(base.salary_raw IS NULL) AS null_salary,
    COUNTIF(base.country_raw IS NULL) AS null_country,
    COUNTIF(base.seniority_level_raw IS NULL) AS null_seniority_level,
    COUNTIF(base.job_category_raw IS NULL) AS null_job_category,

    -- Invalid entries from stg_survey_data
    COUNTIF(base.salary_raw < 0) AS invalid_salary,
    COUNTIF(base.year_raw > EXTRACT(YEAR FROM CURRENT_DATE())) AS future_date,

    -- Mapping issues from int_survey_data__cleaned
    COUNTIF(after_cleaning.country IS NULL) AS intranslatable_country_code,
    COUNTIF(after_cleaning.seniority_level = 'other') AS miscategorized_seniority,
    COUNTIF(after_cleaning.company_size = 'other') AS miscategorized_company_size,

    -- Duplicates in final mart
    (
        SELECT COUNT(*)
        FROM (
            SELECT
                final_mart.year,
                final_mart.country,
                final_mart.seniority_level,
                final_mart.job_category,
                CAST(ROUND(final_mart.salary / 100.0) AS INT64) AS salary_bucket,
                COUNT(*) AS cnt
            FROM final_mart
            GROUP BY
                final_mart.year,
                final_mart.country,
                final_mart.seniority_level,
                final_mart.job_category,
                CAST(ROUND(final_mart.salary / 100.0) AS INT64)
            HAVING COUNT(*) > 1
        )
    ) AS soft_duplicates,

    (
        SELECT COUNT(*)
        FROM (
            SELECT
                base.year_raw,
                base.country_raw,
                base.seniority_level_raw,
                base.job_category_raw,
                base.salary_raw,
                COUNT(*) AS cnt
            FROM base
            GROUP BY
                base.year_raw,
                base.country_raw,
                base.seniority_level_raw,
                base.job_category_raw,
                base.salary_raw
            HAVING COUNT(*) > 1
        )
    ) AS exact_duplicates,

    -- Outliers from int_survey_data__outliers_flagged
    COUNTIF(after_normalization.is_outlier = TRUE) AS outliers_removed

    -- Derived metrics: ratios and quality score
    SAFE_DIVIDE(null_salary, total_entries) AS null_salary_rate,
    SAFE_DIVIDE(null_country, total_entries) AS null_country_rate,
    SAFE_DIVIDE(null_seniority_level, total_entries) AS null_seniority_level_rate,
    SAFE_DIVIDE(null_job_category, total_entries) AS null_job_category_rate,

    SAFE_DIVIDE(invalid_salary, total_entries) AS invalid_salary_rate,
    SAFE_DIVIDE(future_date, total_entries) AS future_date_rate,
    SAFE_DIVIDE(intranslatable_country_code, total_entries) AS intranslatable_country_code_rate,
    SAFE_DIVIDE(miscategorized_seniority, total_entries) AS miscategorized_seniority_rate,
    SAFE_DIVIDE(miscategorized_company_size, total_entries) AS miscategorized_company_size_rate,
    SAFE_DIVIDE(soft_duplicates, total_entries) AS soft_duplicate_rate,
    SAFE_DIVIDE(exact_duplicates, total_entries) AS exact_duplicate_rate,
    SAFE_DIVIDE(outliers_removed, total_entries) AS outlier_rate,

    -- Total invalid entries counted for score (simplified for now)
    (
        null_salary +
        null_country +
        null_seniority_level +
        null_job_category +
        invalid_salary +
        future_date +
        intranslatable_country_code +
        miscategorized_seniority +
        miscategorized_company_size +
        soft_duplicates +
        exact_duplicates +
        outliers_removed
    ) AS total_issues,

    -- Data quality score (inverse of issue rate)
    ROUND(100 - 100 * SAFE_DIVIDE(
        null_salary +
        null_country +
        null_seniority_level +
        null_job_category +
        invalid_salary +
        future_date +
        intranslatable_country_code +
        miscategorized_seniority +
        miscategorized_company_size +
        soft_duplicates +
        exact_duplicates +
        outliers_removed,
        total_entries
    ), 2) AS data_quality_score

FROM base
LEFT JOIN after_cleaning ON base.entry_number = after_cleaning.entry_number
LEFT JOIN after_normalization ON base.entry_number = after_normalization.entry_number

{% if is_incremental() %}
    -- Avoid re-inserting for the same run_date (safety measure)
    WHERE CURRENT_DATE() > (SELECT MAX(DATE(run_date)) FROM {{ this }})
{% endif %}

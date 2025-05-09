-- stg_survey_data.sql
{{ config(
    tags=['layer:stg', 'domain:survey'],
    contract={"enforced": false}
) }}

-- This model selects raw survey data, casts data types,
-- generates a unique ID, adds a processing timestamp,
-- and performs initial basic cleaning/standardization
-- on text fields.

SELECT
    {{ dbt_utils.generate_surrogate_key(['year', 'country', 'seniority_level', 'job_category', 'salary']) }} AS survey_entry_id, -- Generate a unique ID

    ROW_NUMBER() OVER (ORDER BY year, country, seniority_level, job_category, salary) AS entry_number, -- for human readability

    CAST(year AS INT) AS year_raw,
    
    TRIM(LOWER(seniority_level)) AS seniority_level_raw,

    TRIM(LOWER(employment_status)) AS employment_status_raw,

    CAST(salary AS NUMERIC) AS salary_raw,

    TRIM(LOWER(country)) AS country_raw, -- Store the cleaned raw string for joining

    TRIM(LOWER(company_size)) AS company_size_raw,

    TRIM(LOWER(job_category)) AS job_category_raw,

    {{ dbt_date.now() }} AS dbt_processed_at -- Timestamp when this record was processed by dbt

FROM
    {{ source('survey_data', 'developer_salaries') }}

WHERE
    -- Add basic filtering for clearly invalid records if necessary
    salary IS NOT NULL AND salary > 0
    AND year IS NOT NULL AND year BETWEEN 2000 AND EXTRACT(YEAR FROM {{ dbt_date.now() }})
ORDER BY entry_number

--LIMIT 1000 -- Limit for testing purposes, remove in production
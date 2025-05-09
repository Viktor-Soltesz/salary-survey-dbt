-- int_suvey_data__cleaned.sql
{{ config(
    tags=['layer:int', 'domain:survey'],
    contract={"enforced": false}
) }}

WITH deduplicated AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY entry_number
            ORDER BY dbt_processed_at
        ) AS rn
    FROM {{ ref('stg_survey_data') }}
),

filtered AS (
    SELECT *
    FROM deduplicated
    WHERE
        rn = 1 AND
        salary_raw IS NOT NULL AND
        country_raw IS NOT NULL AND
        seniority_level_raw IS NOT NULL AND
        job_category_raw IS NOT NULL
),

mapped AS (
    SELECT 
        survey_entry_id,
        entry_number,
        year_raw AS year,

        CASE 
            WHEN seniority_level_raw IN ('se','senior','sr.','lead','staff engineer') THEN 'se'
            WHEN seniority_level_raw IN ('mi','mid-level','mid','intermediate','medior') THEN 'mi'
            WHEN seniority_level_raw IN ('en','entry-level','junior','jr.') THEN 'en'
            WHEN seniority_level_raw IN ('ex','executive','director','vp') THEN 'ex'
            ELSE 'other'
        END AS seniority_level,

        employment_status_raw AS employment_status,
        salary_raw AS salary,
        country_raw AS country,

        CASE 
            WHEN company_size_raw IN ('s','small','1-50','startup','11-50','0-49 employees','<50','under 50 employees') THEN 's'
            WHEN company_size_raw IN ('m','medium','51-500','101-1000','250-999','50-249','100-999') THEN 'm'
            WHEN company_size_raw IN ('l','large','501+','enterprise','1000+','>1000') THEN 'l'
            ELSE 'other'
        END AS company_size,

        job_category_raw AS job_category

    FROM filtered
)

SELECT *
FROM mapped

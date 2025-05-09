-- int_survey_data__outliers_flagged.sql
{{ config(
    tags=['layer:int', 'domain:survey'],
    contract={"enforced": false}
) }}

WITH base AS (
    SELECT *
    FROM {{ ref('int_survey_data__normalized') }}
),

median_calc AS (
    SELECT
        APPROX_QUANTILES(salary_norm, 100)[OFFSET(50)] AS median_salary
    FROM base
),

mad_calc AS (
    SELECT
        APPROX_QUANTILES(ABS(salary_norm - mc.median_salary), 100)[OFFSET(50)] AS mad
    FROM base, median_calc mc
),

stats AS (
    SELECT 
        mc.median_salary,
        mad_calc.mad
    FROM median_calc mc, mad_calc
),

flagged AS (
    SELECT
        b.*,
        ((0.6745 * (b.salary_norm - s.median_salary)) / NULLIF(s.mad, 0)) AS z_score_modif,
        CASE 
            WHEN ABS((0.6745 * (b.salary_norm - s.median_salary)) / NULLIF(s.mad, 0)) > 3.5 
            THEN TRUE ELSE FALSE 
        END AS is_outlier
    FROM base b
    CROSS JOIN stats s
)

SELECT *
FROM flagged

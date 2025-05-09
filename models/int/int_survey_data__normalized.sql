-- int_survey_data__normalized.sql
{{ config(
    tags=['layer:int', 'domain:survey'],
    contract={"enforced": false}
) }}

SELECT
    sd.*,
    ce.country_name,
    ce.gdp_ppp,
    inf.factor_to_2024,
    sd.salary * inf.factor_to_2024 AS salary_norm2024,
    sd.salary / ce.gdp_ppp AS salary_normgdp,
    (sd.salary * inf.factor_to_2024) / ce.gdp_ppp AS salary_norm
FROM {{ ref('int_survey_data__cleaned') }} sd
LEFT JOIN {{ ref('int_seed__country') }} ce
    ON sd.country = ce.country_code
LEFT JOIN {{ ref('stg_seed__inflation_factors') }} inf
    ON sd.year = inf.year

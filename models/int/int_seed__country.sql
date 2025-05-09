-- int_seed__country.sql
{{ config(
    tags=['layer:int', 'domain:survey'],
    contract={"enforced": false}
) }}

SELECT
    cs.country_code,
    cm.country_name,
    cs.gdp_ppp
FROM {{ ref('stg_seed__country_economic_factors') }} cs
LEFT JOIN {{ ref('stg_seed__country_mapping') }} cm
    ON cs.country_code = cm.country_code
WHERE cs.gdp_ppp IS NOT NULL

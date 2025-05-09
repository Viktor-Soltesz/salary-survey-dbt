-- stg_seed__country_economic_factors.sql
{{ config(
    tags=['layer:stg', 'domain:survey'],
    contract={"enforced": false}
) }}

WITH source AS (
    SELECT *
    FROM {{ source('seed_data', 'seed__country_economic_factors') }} -- For source freshness check
)

SELECT
    country_code,
    updated_at,
    median_income_2020_usd,
    mean_income_2020_usd,
    gdp_ppp_usd AS gdp_ppp,
    glassdoor_software_engineer_usd
FROM source
-- stg_seed_inflation_factors.sql
{{ config(
    tags=['layer:stg', 'domain:survey'],
    contract={"enforced": false}
) }}

WITH source AS (
    SELECT *
    FROM {{ ref('seed__inflation_factors') }}
)

SELECT
    CAST(year AS NUMERIC) AS year,
    CAST(factor_to_2024 AS NUMERIC) AS factor_to_2024
FROM source
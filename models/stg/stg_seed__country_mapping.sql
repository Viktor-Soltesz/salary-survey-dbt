-- stg_seed__country_mapping.sql
{{ config(
    tags=['layer:stg', 'domain:survey'],
    contract={"enforced": false}
) }}

WITH source AS (
    SELECT *
    FROM {{ ref('seed__country_mapping') }}
)

SELECT
    country_name,
    country_code
FROM source
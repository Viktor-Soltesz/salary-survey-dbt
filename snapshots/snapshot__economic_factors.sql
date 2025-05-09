-- snapshot__economic_factors.sql
{% snapshot snapshot__economic_factors %}

{{
  config(
    strategy='check',
    unique_key='country_code',
    check_cols=['gdp_ppp']
  )
}}

SELECT * FROM {{ ref('stg_seed__country_economic_factors') }}

{% endsnapshot %}

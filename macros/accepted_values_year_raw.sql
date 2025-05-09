{% test accepted_values_year_raw(model, column_name) %}
SELECT *
FROM {{ model }}
WHERE CAST({{ column_name }} AS INT) NOT IN (2018, 2019, 2020, 2021, 2022, 2023, 2024) --'2018', '2019', '2020', '2021', '2022', '2023', '2024'
{% endtest %}
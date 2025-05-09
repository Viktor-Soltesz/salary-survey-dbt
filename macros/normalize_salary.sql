{% macro normalize_salary(salary, inflation_factor, gdp_ppp_factor) %}
    CASE
        WHEN {{ inflation_factor }} IS NOT NULL AND {{ gdp_ppp_factor }} IS NOT NULL
        THEN {{ salary }} * {{ inflation_factor }} / {{ gdp_ppp_factor }}
        ELSE NULL
    END
{% endmacro %}

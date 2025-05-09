{% macro calculate_modified_z_score(column_name, group_by_columns=[]) %}
    WITH stats AS (
        SELECT
            {% for col in group_by_columns %}{{ col }},{% endfor %}
            MEDIAN({{ column_name }}) AS median_val,
            MEDIAN(ABS({{ column_name }} - MEDIAN({{ column_name }}))) AS mad_val
        FROM {{ this }}
        {% if group_by_columns %} GROUP BY {% for col in group_by_columns %}{{ col }}{% if not loop.last %},{% endif %}{% endfor %}{% endif %}
    )
    SELECT
        t.*,
        CASE
            WHEN s.mad_val > 0 THEN 0.6745 * (t.{{ column_name }} - s.median_val) / s.mad_val
            ELSE NULL
        END AS z_score_modif
    FROM {{ this }} t
    LEFT JOIN stats s
    ON {% for col in group_by_columns %}t.{{ col }} = s.{{ col }} {% if not loop.last %}AND {% endif %}{% endfor %}
{% endmacro %}

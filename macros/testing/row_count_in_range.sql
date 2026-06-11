{#
  test_row_count_in_range(model, min_rows, max_rows)
  Asserts that a model has between min_rows and max_rows rows (inclusive).
  Useful for catching empty models or unexpectedly large result sets.

  Usage (in schema.yml):
    tests:
      - row_count_in_range:
          min_rows: 1000
          max_rows: 10000000
#}
{% test row_count_in_range(model, min_rows=0, max_rows=none) %}
with row_count as (
    select count(*) as n from {{ model }}
)
select n
from row_count
where n < {{ min_rows }}
{% if max_rows is not none %}
   or n > {{ max_rows }}
{% endif %}
{% endtest %}
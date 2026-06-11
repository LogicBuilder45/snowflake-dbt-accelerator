{#
  test_not_null_proportion(model, column_name, at_least)
  Asserts that at least `at_least` proportion (0.0-1.0) of values are not null.
  Useful for columns that allow some nulls but must have high fill rates.

  Usage (in schema.yml):
    - name: email
      tests:
        - not_null_proportion:
            at_least: 0.95
#}
{% test not_null_proportion(model, column_name, at_least=0.0) %}
with validation as (
    select
        sum(case when {{ column_name }} is not null then 1 else 0 end)::float
            / nullif(count(*), 0)                                       as not_null_rate
    from {{ model }}
)
select not_null_rate
from validation
where not_null_rate < {{ at_least }}
{% endtest %}
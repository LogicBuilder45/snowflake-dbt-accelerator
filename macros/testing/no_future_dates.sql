{#
  test_no_future_dates(model, column_name)
  Asserts that no values in column_name are in the future.
  Guards against ETL bugs that produce future timestamps.

  Usage:
    - name: created_at
      tests:
        - no_future_dates
#}
{% test no_future_dates(model, column_name) %}
select {{ column_name }}
from {{ model }}
where {{ column_name }} > current_timestamp()
{% endtest %}
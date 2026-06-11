{#
  incremental_filter(timestamp_column, lookback_days)
  Generates an incremental WHERE clause with a configurable lookback window
  to safely handle late-arriving data.

  Args:
    timestamp_column (str) : Column to filter on (must be a timestamp)
    lookback_days    (int) : Days to re-process on each run (default: project var)

  Usage:
    select * from {{ source('raw', 'events') }}
    {% if is_incremental() %}
      {{ incremental_filter('event_timestamp') }}
    {% endif %}
#}
{% macro incremental_filter(timestamp_column, lookback_days=none) %}
  {% set lookback = lookback_days if lookback_days is not none
                    else var('incremental_lookback_days', 3) %}
  where {{ timestamp_column }} >= (
      select dateadd(day, -{{ lookback }},
          coalesce(max({{ timestamp_column }}), '1900-01-01'::timestamp_ntz))
      from {{ this }}
  )
{% endmacro %}
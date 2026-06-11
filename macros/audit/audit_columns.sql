{#
  audit_columns()
  Appends standard audit metadata columns to any SELECT statement.
  Adds: _loaded_at, _source_relation, _dbt_run_id

  Usage:
    select
        customer_id,
        customer_name,
        {{ audit_columns() }}
    from {{ source('raw', 'customers') }}
#}
{% macro audit_columns() %}
    current_timestamp()                                       as _loaded_at,
    '{{ this.database }}.{{ this.schema }}.{{ this.name }}' as _source_relation,
    '{{ invocation_id }}'                                    as _dbt_run_id
{% endmacro %}
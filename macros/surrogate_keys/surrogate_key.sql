{#
  surrogate_key(columns, algorithm='md5')
  Generates a deterministic, null-safe surrogate key by hashing one or more columns.

  Args:
    columns   (list[str]) : Column names to hash
    algorithm (str)       : 'md5' (default) or 'sha256'

  Usage:
    {{ surrogate_key(['customer_id', 'order_id']) }}
#}
{% macro surrogate_key(columns, algorithm='md5') %}
  {% if columns | length == 0 %}
    {{ exceptions.raise_compiler_error("surrogate_key requires at least one column.") }}
  {% endif %}
  {% set algorithm = algorithm | lower %}
  {% if algorithm not in ['md5', 'sha256'] %}
    {{ exceptions.raise_compiler_error("algorithm must be 'md5' or 'sha256'.") }}
  {% endif %}
  {% set parts = [] %}
  {% for col in columns %}
    {% do parts.append("coalesce(cast(" ~ col ~ " as varchar), '^^NULL^^')") %}
  {% endfor %}
  {% set expr = parts | join(" || '|' || ") %}
  {% if algorithm == 'sha256' %}sha2({{ expr }}, 256)
  {% else %}md5({{ expr }}){% endif %}
{% endmacro %}
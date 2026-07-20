{#
  REUSABLE MACRO
  Macros are dbt's way of writing reusable SQL snippets — like a function.
  This one centralises the "tip as % of fare" calculation so it is defined
  exactly once instead of copy-pasted across models. If the business
  definition changes (e.g. to include tolls in the denominator), you only
  edit it here.

  Usage in a model:
      {{ tip_percentage('tip_amount', 'fare_amount') }} as tip_pct
#}

{% macro tip_percentage(tip_column, fare_column) %}
    case
        when {{ fare_column }} > 0
        then round({{ tip_column }} / {{ fare_column }} * 100, 1)
        else null
    end
{% endmacro %}

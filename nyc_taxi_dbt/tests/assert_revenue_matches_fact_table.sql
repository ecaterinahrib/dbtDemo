{#
  CUSTOM SINGULAR TEST
  Singular tests are just .sql files that return rows when something is
  WRONG. dbt fails the test if the query returns any rows at all — so we
  write the query to "find the problems", not to "prove correctness".

  This test asserts that total revenue in mart_daily_borough_revenue exactly
  matches the sum of total_amount in fct_trips. If these ever drift apart,
  it means the aggregation in the mart introduced a bug (e.g. a bad JOIN
  that drops or duplicates rows).
#}

with fact_total as (
    select round(sum(total_amount), 2) as total from {{ ref('fct_trips') }}
),

mart_total as (
    select round(sum(total_revenue), 2) as total from {{ ref('mart_daily_borough_revenue') }}
)

select
    fact_total.total  as fact_revenue,
    mart_total.total  as mart_revenue,
    abs(fact_total.total - mart_total.total) as difference
from fact_total
cross join mart_total
where abs(fact_total.total - mart_total.total) > 0.01   -- allow tiny float rounding

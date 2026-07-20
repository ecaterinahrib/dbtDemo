{#
  MARTS LAYER — daily borough revenue
  A typical "reporting mart": pre-aggregated to the grain a dashboard
  actually needs (one row per day per borough). Built on top of fct_trips,
  not on the intermediate models directly — marts should reference other
  marts or the fact table, not skip layers back to staging.
#}

select
    pickup_date,
    pickup_borough                          as borough,

    count(*)                                as trip_count,
    sum(total_amount)                       as total_revenue,
    round(avg(fare_amount), 2)               as avg_fare,
    round(avg(tip_pct), 1)                   as avg_tip_pct,
    round(avg(trip_distance_miles), 2)       as avg_distance_miles,
    round(avg(duration_minutes), 1)          as avg_duration_minutes,
    sum(case when is_airport_trip then 1 else 0 end) as airport_trip_count

from {{ ref('fct_trips') }}
where pickup_borough is not null
group by pickup_date, pickup_borough
order by pickup_date, borough

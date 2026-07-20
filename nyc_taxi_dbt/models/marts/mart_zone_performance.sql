{#
  MARTS LAYER — zone performance
  Ranks pickup zones by revenue within each borough using a window function.
  This is the kind of model a "Top zones" dashboard widget would query
  directly — pre-ranked, pre-aggregated, ready to filter and display.
#}

with zone_agg as (

    select
        pickup_borough     as borough,
        pickup_zone_name   as zone_name,

        count(*)                          as trip_count,
        sum(total_amount)                 as total_revenue,
        round(avg(tip_pct), 1)             as avg_tip_pct,
        round(avg(duration_minutes), 1)    as avg_duration_minutes

    from {{ ref('fct_trips') }}
    where pickup_borough is not null
    group by pickup_borough, pickup_zone_name

),

ranked as (

    select
        *,
        rank() over (
            partition by borough
            order by total_revenue desc
        ) as revenue_rank_in_borough,

        round(
            total_revenue / sum(total_revenue) over (partition by borough) * 100,
            2
        ) as pct_of_borough_revenue

    from zone_agg

)

select * from ranked
order by borough, revenue_rank_in_borough

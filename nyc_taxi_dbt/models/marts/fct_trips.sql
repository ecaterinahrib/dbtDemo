{#
  MARTS LAYER — fct_trips
  The atomic fact table: one row per trip, fully cleaned and enriched.
  Materialized as a TABLE (see dbt_project.yml) because it is queried
  repeatedly by the other marts below and by any BI tool connecting to
  this DuckDB file — recomputing it as a view every time would be wasteful.
#}

select
    -- surrogate key — md5 hash of the natural key columns.
    -- (Using DuckDB's built-in md5() instead of dbt_utils.generate_surrogate_key
    md5(
        coalesce(cast(pickup_at as varchar), '') || '-' ||
        coalesce(cast(dropoff_at as varchar), '') || '-' ||
        coalesce(cast(pickup_zone_id as varchar), '') || '-' ||
        coalesce(cast(dropoff_zone_id as varchar), '') || '-' ||
        coalesce(cast(fare_amount as varchar), '')
    ) as trip_id,

    pickup_at,
    dropoff_at,
    date_trunc('day', pickup_at)   as pickup_date,
    extract(hour from pickup_at)   as pickup_hour,
    dayname(pickup_at)              as pickup_day_name,

    pickup_zone_id,
    pickup_borough,
    pickup_zone_name,
    dropoff_zone_id,
    dropoff_borough,
    dropoff_zone_name,

    passenger_count,
    trip_distance_miles,
    duration_minutes,
    speed_mph,

    payment_type,
    case payment_type
        when 1 then 'Credit card'
        when 2 then 'Cash'
        when 3 then 'No charge'
        when 4 then 'Dispute'
        else 'Unknown'
    end as payment_method,

    fare_amount,
    tip_amount,
    tip_pct,
    tolls_amount,
    congestion_surcharge,
    airport_fee,
    is_airport_trip,
    total_amount

from {{ ref('int_taxi_trips_with_zones') }}

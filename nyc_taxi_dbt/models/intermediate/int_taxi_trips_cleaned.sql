{#
  INTERMEDIATE LAYER
  This is where business logic and data quality rules live. Intermediate
  models are materialized as "ephemeral" by default (see dbt_project.yml) —
  they compile inline into whatever references them rather than being
  persisted as their own view or table. This keeps the warehouse tidy while
  still letting you organise logic into named, testable steps.
#}

with trips as (

    select * from {{ ref('stg_taxi_trips') }}

),

with_derived_columns as (

    select
        *,

        -- trip duration in minutes
        date_diff('second', pickup_at, dropoff_at) / 60.0
            as duration_minutes,

        -- average speed — used both for quality filtering and analysis
        case
            when date_diff('second', pickup_at, dropoff_at) > 0
            then trip_distance_miles
                 / (date_diff('second', pickup_at, dropoff_at) / 3600.0)
            else null
        end as speed_mph,

        -- tip as a percentage of the fare
        case
            when fare_amount > 0
            then round(tip_amount / fare_amount * 100, 1)
            else null
        end as tip_pct,

        -- flag airport trips (LaGuardia / JFK flat fee is charged)
        airport_fee > 0 as is_airport_trip

    from trips

),

quality_filtered as (

    select *
    from with_derived_columns
    where
        -- fare sanity bounds
        fare_amount > 0
        and fare_amount < 500

        -- distance sanity bounds
        and trip_distance_miles > 0
        and trip_distance_miles < 100

        -- duration sanity bounds (positive, under 12 hours)
        and duration_minutes > 0
        and duration_minutes < 720

        -- speed sanity bound — catches GPS/data errors
        and (speed_mph is null or speed_mph <= 200)

)

select * from quality_filtered

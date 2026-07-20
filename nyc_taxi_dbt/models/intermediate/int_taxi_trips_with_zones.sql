{#
  INTERMEDIATE LAYER — zone join
  Joins cleaned trips to the zone lookup TWICE: once for pickup, once for
  dropoff. This is the classic "role-playing dimension" pattern — the same
  small dimension table is joined multiple times with different aliases.
#}

with trips as (

    select * from {{ ref('int_taxi_trips_cleaned') }}

),

zones as (

    select * from {{ ref('stg_taxi_zones') }}

),

joined as (

    select
        trips.*,

        pickup_zone.borough     as pickup_borough,
        pickup_zone.zone_name   as pickup_zone_name,

        dropoff_zone.borough    as dropoff_borough,
        dropoff_zone.zone_name  as dropoff_zone_name

    from trips
    left join zones as pickup_zone
        on trips.pickup_zone_id = pickup_zone.zone_id
    left join zones as dropoff_zone
        on trips.dropoff_zone_id = dropoff_zone.zone_id

)

select * from joined

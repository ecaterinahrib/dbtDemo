{#
  STAGING LAYER
  Staging models do the minimum necessary to make raw data usable:
    - rename columns to consistent snake_case
    - cast to correct types
    - light filtering of obviously broken rows (nulls, negative values)
  They do NOT join other tables and do NOT compute business metrics.
  That logic belongs in intermediate/ and marts/.
#}

with source as (

    select * from {{ source('nyc_tlc', 'yellow_tripdata') }}

),

renamed as (

    select
        -- identifiers
        PULocationID                           as pickup_zone_id,
        DOLocationID                           as dropoff_zone_id,
        VendorID                               as vendor_id,
        payment_type,

        -- timestamps
        tpep_pickup_datetime::timestamp        as pickup_at,
        tpep_dropoff_datetime::timestamp       as dropoff_at,

        -- trip facts
        coalesce(passenger_count, 1)::integer  as passenger_count,
        trip_distance::double                  as trip_distance_miles,

        -- money
        fare_amount::double                    as fare_amount,
        tip_amount::double                     as tip_amount,
        tolls_amount::double                   as tolls_amount,
        congestion_surcharge::double            as congestion_surcharge,
        airport_fee::double                    as airport_fee,
        total_amount::double                   as total_amount

    from source

)

select * from renamed

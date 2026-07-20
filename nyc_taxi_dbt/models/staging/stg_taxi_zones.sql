{#
  STAGING LAYER — taxi zone lookup
  Small reference table (265 rows). Renamed to consistent snake_case so
  downstream models can join on predictable column names.
#}

with source as (

    select * from {{ source('nyc_tlc', 'taxi_zone_lookup') }}

),

renamed as (

    select
        LocationID::integer    as zone_id,
        Borough                as borough,
        Zone                   as zone_name,
        service_zone

    from source
    where LocationID is not null

)

select * from renamed

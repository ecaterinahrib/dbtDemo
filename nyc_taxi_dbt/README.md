# NYC Taxi — dbt + DuckDB

A working dbt project on top of the public NYC TLC Yellow Taxi dataset,
using `dbt-duckdb` as the adapter. No data warehouse, no credentials, no
cloud account — everything runs locally against a single `.duckdb` file.

## Project layout

```
nyc_taxi_dbt/
├── dbt_project.yml          # project config — materialization strategy per folder
├── profiles.yml             # DuckDB connection (no secrets needed)
├── packages.yml             # dbt_utils dependency
├── models/
│   ├── staging/             # 1:1 views over raw sources — renamed, typed, lightly cleaned
│   │   ├── sources.yml
│   │   ├── stg_taxi_trips.sql
│   │   ├── stg_taxi_zones.sql
│   │   └── stg_taxi__models.yml
│   ├── intermediate/        # business logic — cleaning rules, joins (ephemeral, not persisted)
│   │   ├── int_taxi_trips_cleaned.sql
│   │   └── int_taxi_trips_with_zones.sql
│   └── marts/                # final tables — what BI tools and analysts query
│       ├── fct_trips.sql
│       ├── mart_daily_borough_revenue.sql
│       ├── mart_zone_performance.sql
│       └── marts__models.yml
├── macros/
│   └── tip_percentage.sql   # reusable tip % calculation
└── tests/
    └── assert_revenue_matches_fact_table.sql   # custom singular test
```

## Setup

```bash
# 1. Install dbt with the DuckDB adapter
pip install dbt-duckdb

# 2. Point dbt at the profiles.yml in this folder (instead of ~/.dbt/)
export DBT_PROFILES_DIR=$(pwd)

# 3. Install dbt_utils
dbt deps

# 4. Test the connection
dbt debug
```

## Running the project

```bash
# Build everything: staging -> intermediate -> marts, in dependency order
dbt run

# Run all tests (not_null, unique, accepted_values, custom singular tests)
dbt test

# Build + test in one go
dbt build

# Build just one model and everything it depends on
dbt run --select +fct_trips

# Build a model and everything that depends on IT
dbt run --select stg_taxi_trips+

# Generate and view interactive documentation (lineage graph!)
dbt docs generate
dbt docs serve
```

## Querying the result

After `dbt run`, everything lives in `nyc_taxi.duckdb`. Query it directly:

```python
import duckdb
con = duckdb.connect('nyc_taxi.duckdb')
print(con.execute("SELECT * FROM marts.fct_trips LIMIT 5").df())
print(con.execute("SELECT * FROM marts.mart_zone_performance ORDER BY revenue_rank_in_borough LIMIT 10").df())
```

## The layered architecture, in one sentence each

- **staging** — make raw data trustworthy: consistent names, correct types, nothing clever.
- **intermediate** — apply business logic and quality rules; not meant to be queried directly.
- **marts** — the final, documented, tested tables that dashboards and analysts actually use.

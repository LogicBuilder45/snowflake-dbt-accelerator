{{
    config(
        materialized        = "incremental",
        unique_key          = "order_key",
        incremental_strategy = "merge",
        on_schema_change    = "append_new_columns",
        cluster_by          = ["ordered_at::date"],
        tags                = ["facts", "orders"]
    )
}}
-- fct_orders
-- Core order fact table. Grain: one row per order.
-- Incremental merge on order_key; lookback window handles late arrivals.

with orders as (

    select * from {{ ref("stg_orders") }}
    {% if is_incremental() %}
      {{ incremental_filter("ordered_at") }}
    {% endif %}

),

customers as (

    select
        customer_key,
        customer_id,
        customer_segment
    from {{ ref("dim_customers") }}

),

final as (

    select
        -- keys
        o.order_key,
        o.order_id,
        c.customer_key,
        o.customer_id,

        -- degenerate dimensions
        o.order_status,
        o.currency_code,
        c.customer_segment,

        -- measures
        o.order_amount,

        -- date keys (date-only for joining to date dimension)
        o.ordered_at::date                                          as ordered_date,
        o.shipped_at::date                                          as shipped_date,
        o.delivered_at::date                                        as delivered_date,

        -- timestamps
        o.ordered_at,
        o.shipped_at,
        o.delivered_at,

        -- derived metrics
        datediff(day, o.ordered_at, o.shipped_at)                  as days_to_ship,
        datediff(day, o.shipped_at, o.delivered_at)                as days_in_transit,
        datediff(day, o.ordered_at, o.delivered_at)                as days_to_deliver,

        -- flags
        (o.order_status = 'cancelled')                             as is_cancelled,
        (o.delivered_at is not null)                               as is_delivered,

        -- audit
        o._loaded_at,
        o._source_relation,
        o._dbt_run_id

    from orders o
    left join customers c using (customer_id)

)

select * from final
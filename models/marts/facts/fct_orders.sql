{{
    config(
        materialized='incremental',
        unique_key='order_key',
        incremental_strategy='merge',
        cluster_by=['ordered_at::date'],
        tags=['facts', 'orders']
    )
}}
-- fct_orders: Core order fact table.
-- Grain: one row per order. Incremental merge on order_key.

with orders as (
    select * from {{ ref('stg_orders') }}
    {% if is_incremental() %}
      {{ incremental_filter('ordered_at') }}
    {% endif %}
),

customers as (
    select customer_key, customer_id
    from {{ ref('dim_customers') }}
),

final as (
    select
        -- keys
        o.order_key,
        o.order_id,
        c.customer_key,

        -- dimensions
        o.order_status,
        o.currency_code,

        -- measures
        o.order_amount,

        -- dates
        o.ordered_at,
        o.shipped_at,
        o.delivered_at,
        datediff('day', o.ordered_at, o.shipped_at)     as days_to_ship,
        datediff('day', o.shipped_at, o.delivered_at)   as days_in_transit,

        -- audit
        o._loaded_at,
        o._source_relation,
        o._dbt_run_id

    from orders o
    left join customers c using (customer_id)
)

select * from final
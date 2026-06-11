{{
    config(
        materialized='table',
        cluster_by=['customer_key'],
        tags=['dimensions', 'customers']
    )
}}
-- dim_customers: Conformed customer dimension.
-- Grain: one row per active customer.

with customers as (
    select * from {{ ref('stg_customers') }}
),

orders as (
    select * from {{ ref('stg_orders') }}
),

-- Derive customer-level order metrics to enrich the dimension
order_summary as (
    select
        customer_id,
        min(ordered_at)              as first_order_at,
        max(ordered_at)              as most_recent_order_at,
        count(*)                     as lifetime_order_count,
        sum(order_amount)            as lifetime_revenue
    from orders
    group by 1
),

final as (
    select
        -- keys
        c.customer_key,
        c.customer_id,

        -- attributes
        c.first_name,
        c.last_name,
        c.full_name,
        c.email_address,

        -- derived behavioral attributes
        o.first_order_at,
        o.most_recent_order_at,
        o.lifetime_order_count,
        o.lifetime_revenue,

        case
            when o.lifetime_order_count is null then 'never_ordered'
            when o.lifetime_order_count = 1     then 'one_time'
            when o.lifetime_order_count <= 5    then 'repeat'
            else 'loyal'
        end                          as customer_segment,

        -- audit
        c._loaded_at,
        c._source_relation,
        c._dbt_run_id

    from customers c
    left join order_summary o using (customer_id)
)

select * from final
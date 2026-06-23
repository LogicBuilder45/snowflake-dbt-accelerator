{{
    config(
        materialized = "table",
        cluster_by   = ["customer_key"],
        tags         = ["dimensions", "customers"]
    )
}}
-- dim_customers
-- Conformed customer dimension enriched with lifetime order metrics.
-- Grain: one row per customer.

with customers as (

    select * from {{ ref("stg_customers") }}

),

order_summary as (

    select
        customer_id,
        min(ordered_at)                          as first_order_at,
        max(ordered_at)                          as most_recent_order_at,
        count(*)                                 as lifetime_order_count,
        sum(order_amount)                        as lifetime_revenue,
        count_if(order_status = "cancelled")     as cancelled_order_count
    from {{ ref("stg_orders") }}
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
        c.is_active,

        -- behavioural metrics
        coalesce(o.lifetime_order_count, 0)      as lifetime_order_count,
        coalesce(o.lifetime_revenue, 0)          as lifetime_revenue,
        coalesce(o.cancelled_order_count, 0)     as cancelled_order_count,
        o.first_order_at,
        o.most_recent_order_at,

        -- derived segment
        case
            when o.lifetime_order_count is null then "never_ordered"
            when o.lifetime_order_count = 1     then "one_time"
            when o.lifetime_order_count <= 5    then "repeat"
            else                                     "loyal"
        end                                      as customer_segment,

        -- dates
        c.created_at,
        c.updated_at,

        -- audit
        c._loaded_at,
        c._source_relation,
        c._dbt_run_id

    from customers c
    left join order_summary o using (customer_id)

)

select * from final
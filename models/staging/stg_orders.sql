-- stg_orders: clean, typed, and renamed order records.
-- One row per order. Applies basic data type coercions only.

with source as (
    select * from {{ source('raw', 'orders') }}
),

renamed as (
    select
        -- ids
        {{ surrogate_key(['id']) }}           as order_key,
        id                                    as order_id,
        customer_id,

        -- attributes
        lower(trim(status))                   as order_status,
        amount::decimal(18,2)                 as order_amount,
        currency_code,

        -- dates
        ordered_at::timestamp_ntz             as ordered_at,
        shipped_at::timestamp_ntz             as shipped_at,
        delivered_at::timestamp_ntz           as delivered_at,

        -- audit
        {{ audit_columns() }}

    from source
    where id is not null
)

select * from renamed
{% snapshot snap_customers %}

{{
    config(
        target_schema='snapshots',
        unique_key='customer_id',
        strategy='timestamp',
        updated_at='updated_at',
        invalidate_hard_deletes=True
    )
}}

-- SCD Type 2 snapshot of the customer dimension.
-- Captures full history of all attribute changes.
select * from {{ source('raw', 'customers') }}

{% endsnapshot %}
-- stg_customers: clean, typed, and renamed customer records from the raw source.
-- One row per customer. No business logic — that lives in intermediate models.

with source as (
    select * from {{ source('raw', 'customers') }}
),

renamed as (
    select
        -- ids
        {{ surrogate_key(['id']) }}          as customer_key,
        id                                   as customer_id,

        -- attributes
        lower(trim(email))                   as email_address,
        case when trim(email) is not null and trim(email) <> '' then true else false end as is_active,
        trim(first_name)                     as first_name,
        trim(last_name)                      as last_name,
        trim(first_name || ' ' || last_name) as full_name,

        -- timestamps
        created_at::timestamp_ntz            as created_at,
        updated_at::timestamp_ntz            as updated_at,

        -- audit
        {{ audit_columns() }}

    from source
    where id is not null  -- exclude records with no PK
)

select * from renamed
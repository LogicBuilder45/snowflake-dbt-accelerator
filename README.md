## snowflake-dbt-accelerator

A practical, plug-and-play dbt starter project for Snowflake that gives teams a clean foundation for staging, testing, and analytics-ready marts without forcing unnecessary complexity.

This repo is intentionally opinionated but lightweight: it helps new data teams move quickly while keeping the project easy to customize as requirements grow.

## What is included

- staging models with SQL hygiene and audit columns
- reusable macros for surrogate keys, incremental filtering, and common tests
- sample marts for customer and order analysis
- dbt project-level defaults for Snowflake development workflows
- example CI validation workflow for GitHub Actions

## Project layout

```text
snowflake-dbt-accelerator/
+-- .github/
¦   +-- workflows/
¦       +-- dbt-ci.yml
+-- analyses/
+-- docs/
+-- macros/
¦   +-- audit/
¦   +-- incremental/
¦   +-- testing/
+-- models/
¦   +-- marts/
¦   +-- staging/
+-- snapshots/
+-- tests/
+-- .env.example
+-- .gitignore
+-- CONTRIBUTING.md
+-- LICENSE
+-- README.md
+-- dbt_project.yml
+-- packages.yml
+-- profiles.yml.sample
+-- .gitignore
```

## Quick start

### 1) Clone the repo

```bash
git clone https://github.com/LogicBuilder45/snowflake-dbt-accelerator.git my-dbt-project
cd my-dbt-project
```

### 2) Install Python and dbt dependencies

```bash
python -m venv .venv
source .venv/bin/activate
python -m pip install --upgrade pip
pip install dbt-snowflake
```

### 3) Install dbt packages

```bash
dbt deps
```

### 4) Configure your Snowflake profile

Copy the sample profile into your local dbt config and adjust the values for your environment:

```bash
cp profiles.yml.sample ~/.dbt/profiles.yml
```

Then update the values to match your account and warehouse:

```yaml
snowflake_dbt_accelerator:
  target: dev
  outputs:
    dev:
      type: snowflake
      account: "<your_account>.snowflakecomputing.com"
      user: "<your_user>"
      password: "<your_password>"
      role: TRANSFORMER
      database: ANALYTICS_DEV
      warehouse: TRANSFORMING_WH
      schema: DBT_DEV
      threads: 4
      query_tag: dbt_dev
```

### 5) Validate your setup

```bash
dbt debug
```

### 6) Run the project

```bash
dbt build
```

## Repository conventions

This project follows a straightforward, common-sense dbt structure:

- `staging` models clean and standardize raw data
- `marts` models create business-facing tables for reporting and consumption
- macros centralize repeatable SQL patterns
- generic tests help enforce data quality without overcomplicating the project

## Included macro patterns

### `surrogate_key`

Creates a deterministic hash key for entity records.

```sql
{{ surrogate_key(['customer_id', 'order_id']) }}
```

### `audit_columns`

Adds standard auditing metadata to staging outputs.

```sql
select
    customer_id,
    {{ audit_columns() }}
from {{ source('raw', 'customers') }}
```

### `incremental_filter`

Keeps incremental logic safe and predictable with late-arriving data handling.

```sql
{% if is_incremental() %}
    {{ incremental_filter('ordered_at', lookback_days=3) }}
{% endif %}
```

## Testing approach

The project ships with custom dbt tests for common patterns such as:

- row count thresholds
- no future dates
- not-null proportion checks
- auditability of staging and marts

Run them with:

```bash
dbt test
```

## CI/CD

A GitHub Actions workflow is included to make validation easier for contributors and teams:

```bash
.github/workflows/dbt-ci.yml
```

It is designed to install dependencies and run a lightweight dbt validation pass as a baseline for pull requests.

## Customization guide

To make this repo useful for a real warehouse, you will usually:

1. swap the source names in `models/staging/_sources.yml`
2. replace sample model logic with your own downstream business rules
3. adjust warehouse names, database names, and deployment targets in `profiles.yml.sample`
4. extend macros and tests for your domain language and quality standards

## Contributing

Contributions are welcome. Please see [CONTRIBUTING.md](CONTRIBUTING.md) for the project workflow and expectations.

## License

This project is licensed under the Apache 2.0 License. See [LICENSE](LICENSE) for details.

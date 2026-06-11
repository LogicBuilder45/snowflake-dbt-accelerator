<p align="center">
  <img src="https://img.shields.io/badge/dbt-1.7%2B-orange?style=flat-square&logo=dbt" />
  <img src="https://img.shields.io/badge/Snowflake-compatible-29B5E8?style=flat-square&logo=snowflake" />
  <img src="https://img.shields.io/badge/license-Apache%202.0-blue?style=flat-square" />
  <img src="https://img.shields.io/badge/PRs-welcome-brightgreen?style=flat-square" />
</p>

# ❄️ snowflake-dbt-accelerator

> A production-ready dbt project template for Snowflake enterprise data warehouses. Includes pre-built macros for common EDW patterns, a full testing framework, and a CI/CD pipeline out of the box.

Built for data engineers who are tired of reinventing the wheel on every project.

---

## ✨ What's Included

| Category | What You Get |
|---|---|
| **Macros** | Surrogate keys, audit columns, incremental load strategies, SCD Type 2 |
| **Testing** | Generic + singular tests, data quality framework, freshness checks |
| **CI/CD** | GitHub Actions workflows for slim CI, full test runs, and production deploys |
| **Documentation** | Auto-generated dbt docs with custom overview page |
| **Seeds** | Reference data patterns (date dimensions, fiscal calendars) |
| **Snapshots** | SCD Type 2 snapshot configurations for common patterns |

---

## 🚀 Quick Start

### 1. Use this template

Click **"Use this template"** on GitHub, or clone directly:

```bash
git clone https://github.com/LogicBuilder45/snowflake-dbt-accelerator.git my-dw-project
cd my-dw-project
```

### 2. Install dependencies

```bash
pip install dbt-snowflake
dbt deps
```

### 3. Configure your profile

Copy the sample profile and fill in your Snowflake credentials:

```bash
cp profiles/profiles.yml.sample ~/.dbt/profiles.yml
```

```yaml
# ~/.dbt/profiles.yml
snowflake_dbt_accelerator:
  target: dev
  outputs:
    dev:
      type: snowflake
      account: "<your_account>"
      user: "<your_user>"
      password: "<your_password>"       # or use key-pair / SSO
      role: TRANSFORMER
      database: ANALYTICS_DEV
      warehouse: TRANSFORMING_WH
      schema: DBT_{{ env_var('USER', 'DEV') }}
      threads: 4
    prod:
      type: snowflake
      account: "<your_account>"
      user: "<your_svc_account>"
      private_key_path: /secrets/snowflake_key.p8
      role: TRANSFORMER_PROD
      database: ANALYTICS
      warehouse: TRANSFORMING_WH_PROD
      schema: CORE
      threads: 8
```

### 4. Validate the setup

```bash
dbt debug
dbt compile
```

---

## 📦 Macro Reference

### Surrogate Keys

```sql
-- Generate a deterministic surrogate key from one or more columns
{{ surrogate_key(['customer_id', 'order_id']) }}

-- With custom algorithm (default: MD5; options: SHA256)
{{ surrogate_key(['customer_id'], algorithm='sha256') }}
```

### Audit Columns

```sql
-- Add standard audit columns to any model
{{ audit_columns() }}
-- Adds: _loaded_at, _source_relation, _dbt_run_id
```

### Incremental Strategies

```sql
-- Append-only incremental with configurable lookback window
{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='event_id'
) }}

{{ incremental_filter(
    timestamp_column='event_timestamp',
    lookback_days=3
) }}
```

### SCD Type 2

```sql
-- Full SCD Type 2 implementation as a snapshot
{{ config(
    target_schema='snapshots',
    unique_key='customer_id',
    strategy='timestamp',
    updated_at='updated_at'
) }}

{{ scd2_snapshot(source_model='stg_customers') }}
```

---

## 🏗️ Project Structure

```
snowflake-dbt-accelerator/
├── macros/
│   ├── surrogate_keys/       # Key generation macros
│   ├── audit/                # Audit column macros
│   ├── incremental/          # Incremental load helpers
│   └── testing/              # Custom test macros
├── models/
│   ├── staging/              # Raw source cleaning (1:1 with source tables)
│   ├── intermediate/         # Business logic joins & transformations
│   └── marts/                # Final consumer-facing models
├── tests/
│   ├── generic/              # Reusable generic tests
│   └── singular/             # One-off data quality assertions
├── snapshots/                # SCD Type 2 snapshot definitions
├── seeds/                    # Static reference data
├── analyses/                 # Ad-hoc analytical SQL
├── docs/                     # Custom documentation overrides
└── .github/
    └── workflows/            # CI/CD pipeline definitions
```

---

## 🧪 Testing Framework

This template ships with an opinionated testing strategy:

### Layer-by-layer testing philosophy

| Layer | Test Focus |
|---|---|
| `staging` | Source freshness, not-null on PKs, accepted values |
| `intermediate` | Referential integrity, row count assertions |
| `marts` | Business rule validation, no fan-out joins |

### Running tests

```bash
# Run all tests
dbt test

# Run only staging tests
dbt test --select staging

# Run tests and show failures inline
dbt test --store-failures
```

### Custom generic tests included

- `test_row_count_in_range` — Assert a model has between N and M rows
- `test_no_future_dates` — Assert no timestamps are in the future
- `test_referential_integrity` — Cross-model FK validation with helpful error output
- `test_sum_equals` — Assert a metric column sums to an expected value

---

## ⚙️ CI/CD Pipelines

### Slim CI (on Pull Request)

Runs only models and tests affected by the PR using dbt's `state:modified+` selector. Keeps PR checks fast even on large projects.

```yaml
# .github/workflows/slim_ci.yml
# Triggers on: pull_request to main
# Does: dbt build --select state:modified+ --defer --state ./prod-artifacts
```

### Full Test Run (nightly)

```yaml
# .github/workflows/nightly.yml
# Triggers on: schedule (2am UTC)
# Does: dbt build --full-refresh (for incremental models), dbt source freshness
```

### Production Deploy (on merge to main)

```yaml
# .github/workflows/prod_deploy.yml
# Triggers on: push to main
# Does: dbt build --target prod, uploads manifest.json as artifact for slim CI
```

---

## 🔧 Snowflake-Specific Optimizations

This template encodes Snowflake best practices by default:

- **Clustering keys** — Macro helper to declare cluster keys that match your query patterns
- **Transient tables** — Staging models use `transient=true` to avoid Fail-Safe storage costs
- **Query tags** — Every dbt run is tagged with `dbt_model`, `dbt_run_id`, `target_name` for cost attribution in Snowflake's `QUERY_HISTORY`
- **Warehouse scaling** — Multi-cluster warehouse recommendations documented per model layer
- **Zero-copy cloning** — `clone_for_dev.sql` script to clone prod → dev database in seconds

---

## 📋 Conventions

### Model naming

```
stg_<source>__<entity>.sql       # staging (double underscore separates source from entity)
int_<verb>_<entity>.sql          # intermediate
fct_<entity>.sql                 # fact table
dim_<entity>.sql                 # dimension table
```

### Column naming

```sql
-- Primary keys always end in _id
customer_id, order_id

-- Foreign keys reference the target table
customer_id (in orders model = FK to dim_customer)

-- Dates end in _date, timestamps end in _at
created_date, updated_at, loaded_at

-- Booleans start with is_ or has_
is_active, has_subscription
```

---

## 🤝 Contributing

Contributions are welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md) before submitting a PR.

### Ideas for contributions
- New macro patterns
- Additional generic tests
- Platform-specific optimizations
- Documentation improvements

---

## 📖 Citation

If you use this project in your work or reference it in a publication, please cite it:

```bibtex
@software{snowflake_dbt_accelerator,
  title  = {snowflake-dbt-accelerator: A production-ready dbt template for Snowflake EDW},
  author = {Saqib Khan},
  year   = {2026},
  url    = {https://github.com/LogicBuilder45/snowflake-dbt-accelerator}
}
```

---

## 📄 License

Apache 2.0 — see [LICENSE](LICENSE) for details.

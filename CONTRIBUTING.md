# Contributing to snowflake-dbt-accelerator

Thank you for your interest in contributing! This project welcomes contributions of all kinds.

## Ways to Contribute

- **New macros**: Add macros for patterns not yet covered
- **Bug fixes**: Fix issues with existing macros or tests
- **Documentation**: Improve docstrings, README, or add examples
- **Tests**: Add test coverage for macros

## Development Setup

1. Fork and clone the repo
2. Create a virtual environment: `python -m venv .venv && source .venv/bin/activate`
3. Install dbt: `pip install dbt-snowflake`
4. Install packages: `dbt deps`
5. Copy the sample profile: `cp profiles/profiles.yml.sample ~/.dbt/profiles.yml`
6. Fill in your Snowflake credentials

## Conventions

### Macro documentation
Every macro must include a Jinja docstring explaining:
- What it does
- All arguments and their types
- At least one usage example

### SQL style
- 4-space indentation
- Uppercase SQL keywords
- Column aliases for every expression
- Comments explaining non-obvious logic

### Testing
- All new models must have schema.yml entries with tests
- All new macros must have at least one example in the README

## Pull Request Process

1. Open an issue first to discuss significant changes
2. Branch naming: `feature/my-thing`, `fix/the-bug`, `docs/improve-readme`
3. Keep PRs focused — one logical change per PR
4. Update the README if you add a new macro or change behavior
5. Tests must pass: `dbt build`

## Code of Conduct

Be kind and constructive. We follow the [Contributor Covenant](https://www.contributor-covenant.org/).
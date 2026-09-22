# dbt project overview

This project intentionally follows a simple layered pattern:

- staging: raw-to-cleaned transformations, light type coercion, null checks
- marts: domain-centric final tables for analysts and downstream tools
- macros: reusable SQL utilities and testing patterns

The goal is to keep the warehouse architecture readable, testable, and easy to extend without creating heavy abstraction layers.

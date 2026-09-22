from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parent.parent


class ProjectSqlContractTests(unittest.TestCase):
    def test_customers_stage_exposes_is_active(self):
        stage_sql = (ROOT / "models" / "staging" / "stg_customers.sql").read_text(encoding="utf-8")
        self.assertIn("is_active", stage_sql)

    def test_fact_sql_uses_valid_snowflake_literals(self):
        fact_sql = (ROOT / "models" / "marts" / "facts" / "fct_orders.sql").read_text(encoding="utf-8")
        self.assertNotIn('datediff("day"', fact_sql)
        self.assertNotIn('order_status = "cancelled"', fact_sql)

    def test_dimension_sql_uses_valid_snowflake_literals(self):
        dim_sql = (ROOT / "models" / "marts" / "dimensions" / "dim_customers.sql").read_text(encoding="utf-8")
        self.assertNotIn('order_status = "cancelled"', dim_sql)
        self.assertNotIn('count_if(order_status = "cancelled")', dim_sql)


if __name__ == "__main__":
    unittest.main()

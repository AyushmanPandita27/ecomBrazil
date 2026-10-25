# Decisions log

One entry per real choice. These become our interview answers.

| Date | Decision | Why | Alternative we rejected |
| --- | --- | --- | --- |
| 2026-10-26 | Use the real Olist dataset as the source | Real messy data (nulls, status lifecycles, BRL prices) beats generated data | Faker generator: clean, unrealistic |
| 2026-10-26 | RustFS as the local data lake | S3-compatible, maintained, official images; code moves to AWS S3 unchanged | MinIO: community images discontinued Oct 2025 |
| 2026-10-26 | Separate Postgres for source data and Airflow metadata | Pipeline data and orchestrator state never mix; mirrors production | One shared Postgres: simpler but couples them |
| 2026-10-26 | Airflow 3 `standalone` + LocalExecutor | One container, light on a laptop, real executor | Full Celery setup: Redis + workers, too heavy for local dev |

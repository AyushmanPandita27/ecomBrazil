# Olist Data Platform

An end-to-end, locally runnable data platform built on the real
[Olist Brazilian e-commerce dataset](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)
(~100k orders, 2016–2018): Postgres source → S3-compatible data lake → dbt models → dashboard,
orchestrated by Airflow.

## Stack (Week 1)

| Service | What it is | Address |
| --- | --- | --- |
| `source-db` | Postgres 16 with the Olist source tables | `localhost:5433` (user/pass `olist`/`olist`) |
| `rustfs` | S3-compatible object storage = the data lake | API `localhost:9000`, console http://localhost:9001 |
| `lake-init` | Creates the `olist-lake` bucket on start | runs once, then exits |
| `airflow` | Airflow 3.2 (standalone) | http://localhost:8080 |
| `airflow-db` | Postgres for Airflow metadata | internal only |

Lake console login: `lakeadmin` / `lakeadmin123` (change in `.env`).

> Why RustFS instead of MinIO? MinIO stopped publishing its community Docker images in Oct 2025
> and archived the repo in 2026. RustFS speaks the same S3 API, so our boto3 code would run
> unchanged against AWS S3.

## One-time setup (Windows)

1. **Docker Desktop** running with the WSL 2 backend. In *Settings → Resources*, give it at least 6 GB memory.
2. **Git for Windows** (https://git-scm.com). Before cloning, run once:
   `git config --global core.autocrlf input` so scripts keep Unix line endings.
3. Put the 9 Olist CSVs in `data\raw\olist\`.

Run it in PowerShell from the project folder (Windows has no `make`, so use the docker commands directly):

```powershell
docker compose up -d --build          # start (first run ~3-5 min)
powershell -ExecutionPolicy Bypass -File scripts\check_setup.ps1
docker compose logs -f airflow        # follow Airflow logs
docker compose down                   # stop (data kept)
docker compose down -v                # stop and wipe all data
```

Then open http://localhost:8080 and trigger the **setup_check** DAG.

## One-time setup (macOS, Apple Silicon)

1. Install **Docker Desktop for Mac (Apple Silicon)** from https://www.docker.com/products/docker-desktop/
   and start it. In *Settings → Resources*, give it at least **6 GB memory** (8 GB is better).
2. Put the 9 Olist CSVs in `data/raw/olist/`:
   - either unzip your Kaggle download there, or
   - `kaggle datasets download -d olistbr/brazilian-ecommerce -p data/raw/olist --unzip`
3. (Optional) Local Python env for scripts/tests: `make venv`

## Run it

```bash
make up        # first run builds the Airflow image: ~3-5 min
make check     # all lines should say OK (Airflow UI may need a minute)
```

Then open http://localhost:8080, find the **setup_check** DAG, unpause it and trigger it.
All three tasks green = the stack is ready for Week 1 work.

| Command | Does |
| --- | --- |
| `make up` | start everything |
| `make down` | stop (data kept) |
| `make reset` | stop and wipe all data |
| `make logs` | follow Airflow logs |
| `make ps` | container status |

## Project layout

```
airflow/            Airflow image (Dockerfile + Python deps)
dags/               Airflow DAGs
src/ingestion/      Python extract/load code (importable as `ingestion.*` inside Airflow)
data/raw/olist/     Olist CSVs (git-ignored)
scripts/            helper scripts
docs/DECISIONS.md   why we chose what we chose
tests/              pytest tests
```

## Week 1 tasks

See the project plan. In short: load Olist into `source-db` + replay script,
incremental extract Postgres → lake (Parquet, partitioned by order date),
BRL→USD exchange-rate extract → lake.

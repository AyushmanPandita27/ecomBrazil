"""Run this DAG once after `make up` to prove every piece of the stack talks to the others."""
from datetime import datetime

from airflow.sdk import dag, task


@dag(schedule=None, start_date=datetime(2026, 10, 1), catchup=False, tags=["setup"])
def setup_check():
    @task
    def check_source_db() -> str:
        from ingestion.connections import source_db_conn

        with source_db_conn() as conn, conn.cursor() as cur:
            cur.execute("select version()")
            return cur.fetchone()[0]

    @task
    def check_lake() -> str:
        from ingestion.connections import lake_bucket, lake_client

        s3 = lake_client()
        key = "_setup_check/hello.txt"
        s3.put_object(Bucket=lake_bucket(), Key=key, Body=b"lake is reachable")
        body = s3.get_object(Bucket=lake_bucket(), Key=key)["Body"].read().decode()
        return body

    @task
    def check_olist_files() -> list[str]:
        from pathlib import Path

        files = sorted(p.name for p in Path("/opt/airflow/data/raw/olist").glob("*.csv"))
        if len(files) < 9:
            raise FileNotFoundError(
                f"Expected 9 Olist CSVs in data/raw/olist, found {len(files)}: {files}"
            )
        return files

    [check_source_db(), check_lake(), check_olist_files()]


setup_check()

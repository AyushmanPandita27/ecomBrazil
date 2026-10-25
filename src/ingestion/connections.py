"""Shared connection helpers. Every setting comes from environment variables
(set in docker-compose.yml inside Docker, or exported in your shell locally)."""
import os

import boto3
import psycopg2


def source_db_conn():
    """Connection to the Olist source Postgres."""
    return psycopg2.connect(
        host=os.getenv("SOURCE_DB_HOST", "localhost"),
        port=int(os.getenv("SOURCE_DB_PORT", "5433")),
        user=os.getenv("SOURCE_DB_USER", "olist"),
        password=os.getenv("SOURCE_DB_PASSWORD", "olist"),
        dbname=os.getenv("SOURCE_DB_NAME", "olist"),
    )


def lake_client():
    """boto3 S3 client pointed at the local RustFS lake (same code works on real S3)."""
    return boto3.client(
        "s3",
        endpoint_url=os.getenv("LAKE_ENDPOINT", "http://localhost:9000"),
        aws_access_key_id=os.getenv("AWS_ACCESS_KEY_ID", "lakeadmin"),
        aws_secret_access_key=os.getenv("AWS_SECRET_ACCESS_KEY", "lakeadmin123"),
        region_name=os.getenv("AWS_DEFAULT_REGION", "us-east-1"),
    )


def lake_bucket() -> str:
    return os.getenv("LAKE_BUCKET", "olist-lake")

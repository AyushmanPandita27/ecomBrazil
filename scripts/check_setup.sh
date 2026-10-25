#!/usr/bin/env bash
# Quick checks from your Mac that each service is up.
set -u
ok()   { printf "  \033[32mOK\033[0m   %s\n" "$1"; }
bad()  { printf "  \033[31mFAIL\033[0m %s\n" "$1"; }

echo "Checking tools..."
command -v docker >/dev/null && ok "docker $(docker --version | awk '{print $3}' | tr -d ,)" || bad "docker not installed"
docker compose version >/dev/null 2>&1 && ok "docker compose" || bad "docker compose missing"
command -v git >/dev/null && ok "git" || bad "git not installed"
command -v python3 >/dev/null && ok "python3 $(python3 --version | awk '{print $2}')" || bad "python3 not installed"

echo "Checking services..."
docker exec olist-source-db pg_isready -U olist >/dev/null 2>&1 && ok "source Postgres (localhost:5433)" || bad "source Postgres"
curl -sf http://localhost:9000/health >/dev/null && ok "RustFS lake API (localhost:9000)" || bad "RustFS lake API"
curl -sf -o /dev/null http://localhost:9001 && ok "RustFS console (http://localhost:9001)" || bad "RustFS console"
curl -sf -o /dev/null http://localhost:8080 && ok "Airflow UI (http://localhost:8080)" || bad "Airflow UI (can take ~1-2 min after start)"

echo "Checking Olist data..."
n=$(ls data/raw/olist/*.csv 2>/dev/null | wc -l | tr -d ' ')
[ "$n" -ge 9 ] && ok "$n Olist CSVs in data/raw/olist" || bad "found $n Olist CSVs in data/raw/olist (need 9)"

# Quick health check for Windows (PowerShell). Run from the project folder:
#   powershell -ExecutionPolicy Bypass -File scripts\check_setup.ps1
function Ok($m)  { Write-Host "  OK   $m" -ForegroundColor Green }
function Bad($m) { Write-Host "  FAIL $m" -ForegroundColor Red }
function Up($url) { try { Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 5 | Out-Null; $true } catch { $false } }

Write-Host "Checking tools..."
if (Get-Command docker -ErrorAction SilentlyContinue) { Ok (docker --version) } else { Bad "docker not installed" }
docker compose version *> $null; if ($LASTEXITCODE -eq 0) { Ok "docker compose" } else { Bad "docker compose missing" }
if (Get-Command git -ErrorAction SilentlyContinue) { Ok "git" } else { Bad "git not installed" }

Write-Host "Checking services..."
docker exec olist-source-db pg_isready -U olist *> $null
if ($LASTEXITCODE -eq 0) { Ok "source Postgres (localhost:5433)" } else { Bad "source Postgres" }
if (Up "http://localhost:9000/health") { Ok "RustFS lake API (localhost:9000)" } else { Bad "RustFS lake API" }
if (Up "http://localhost:9001")        { Ok "RustFS console (http://localhost:9001)" } else { Bad "RustFS console" }
if (Up "http://localhost:8080")        { Ok "Airflow UI (http://localhost:8080)" } else { Bad "Airflow UI (can take 1-2 min after start)" }

Write-Host "Checking Olist data..."
$n = (Get-ChildItem data\raw\olist\*.csv -ErrorAction SilentlyContinue).Count
if ($n -ge 9) { Ok "$n Olist CSVs in data\raw\olist" } else { Bad "found $n Olist CSVs in data\raw\olist (need 9)" }

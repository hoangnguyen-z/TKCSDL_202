param(
    [string]$ContainerName = "tkcsdl-sqlserver",
    [string]$EnvFile = ".env",
    [string]$DatabaseRoot = "database"
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path $EnvFile)) {
    throw "Missing $EnvFile. Copy .env.example to .env and set a strong SA password first."
}

$envMap = @{}
Get-Content $EnvFile | ForEach-Object {
    if ($_ -match '^\s*#' -or [string]::IsNullOrWhiteSpace($_)) {
        return
    }
    $parts = $_.Split('=', 2)
    if ($parts.Count -eq 2) {
        $envMap[$parts[0].Trim()] = $parts[1].Trim()
    }
}

$saPassword = $envMap["MSSQL_SA_PASSWORD"]
if (-not $saPassword) {
    throw "MSSQL_SA_PASSWORD is missing in $EnvFile."
}

$scriptOrder = @(
    "00_create_database.sql",
    "01_tables.sql",
    "02_constraints.sql",
    "03_indexes.sql",
    "04_views.sql",
    "05_functions.sql",
    "06_procedures.sql",
    "07_triggers.sql",
    "08_seed_reference_data.sql",
    "09_seed_demo_data.sql"
)

function Invoke-SqlFile {
    param(
        [string]$FilePath
    )

    Write-Host "Running $FilePath ..."
    $sql = Get-Content -Raw $FilePath
    $wrapped = @"
SET NOCOUNT ON;
$sql
"@
    $wrapped | docker exec -i $ContainerName /bin/bash -c "
if [ -x /opt/mssql-tools18/bin/sqlcmd ]; then
  /opt/mssql-tools18/bin/sqlcmd -C -S localhost -U sa -P '$saPassword' -b -i /dev/stdin
else
  /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P '$saPassword' -b -i /dev/stdin
fi
" | Out-Host
}

foreach ($name in $scriptOrder) {
    $fullPath = Join-Path $DatabaseRoot $name
    if (-not (Test-Path $fullPath)) {
        throw "Missing script: $fullPath"
    }
}

Write-Host "Waiting for SQL Server container health ..."
for ($i = 0; $i -lt 30; $i++) {
    $state = docker inspect --format "{{if .State.Health}}{{.State.Health.Status}}{{else}}{{.State.Status}}{{end}}" $ContainerName 2>$null
    if ($state -eq "healthy" -or $state -eq "running") {
        break
    }
    Start-Sleep -Seconds 5
}

foreach ($name in $scriptOrder) {
    Invoke-SqlFile -FilePath (Join-Path $DatabaseRoot $name)
}

Write-Host "Database initialization completed."

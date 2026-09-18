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
    $sql = (Get-Content -Raw -Encoding UTF8 $FilePath).TrimStart([char]0xFEFF)
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

Write-Host "Copying database scripts to container ..."
docker exec $ContainerName /bin/bash -c "mkdir -p /tmp/database"
docker cp "$DatabaseRoot/." "$ContainerName`:/tmp/database"

foreach ($name in $scriptOrder) {
    Write-Host "Running $name ..."
    docker exec -i $ContainerName /bin/bash -c "
if [ -x /opt/mssql-tools18/bin/sqlcmd ]; then
  /opt/mssql-tools18/bin/sqlcmd -C -I -S localhost -U sa -P '$saPassword' -b -i /tmp/database/$name
else
  /opt/mssql-tools/bin/sqlcmd -I -S localhost -U sa -P '$saPassword' -b -i /tmp/database/$name
fi
" | Out-Host
    if ($LASTEXITCODE -ne 0) {
        throw "Script execution failed on $name with exit code $LASTEXITCODE"
    }
}

Write-Host "Database initialization completed."

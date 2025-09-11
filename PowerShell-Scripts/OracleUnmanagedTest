# ==========================
# CONFIGURATION VARIABLES # ODP.NET Unmanaged Driver 
# https://www.oracle.com/database/technologies/appdev/ocmt.html
# ==========================
$DbHost          = "HOST"
$Port            = 1521
$ServiceName     = "SERVICE_NAME"
$UserName        = "OracleUser"
$Password        = "PW"   # Use Get-Credential in production
$SqlQuery        = "SELECT * FROM FACTSALES WHERE ROWNUM <= 40000"
$FetchMultiplier = 1000  # Optional: Debug on large datasets
# ==========================

Build connection string
$connStr = "User Id=$UserName;Password=$Password;Data Source=(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=$DbHost)(PORT=$Port))(CONNECT_DATA=(SERVICE_NAME=$ServiceName)))"

# Create connection using system-registered Oracle.DataAccess provider
try {
    $conn = [System.Data.Common.DbProviderFactories]::GetFactory("Oracle.DataAccess.Client").CreateConnection()
    $conn.ConnectionString = $connStr
} catch {
    Write-Error "Failed to create Oracle connection using system-registered provider: $_"
    exit 1
}

# Start stopwatch
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

try {
    $conn.Open()
    $connectTime = $stopwatch.Elapsed.TotalSeconds

    $cmd = $conn.CreateCommand()
    $cmd.CommandText = $SqlQuery

    $reader = $cmd.ExecuteReader()
    $executeTime = ($stopwatch.Elapsed.TotalSeconds - $connectTime)

    # Try setting FetchSize if supported
    if ($FetchMultiplier -and $reader.RowSize) {
        try {
            $reader.FetchSize = $reader.RowSize * $FetchMultiplier
        } catch {
            Write-Warning "Unable to set FetchSize. Continuing with default."
        }
    }

    $rows = 0
    while ($reader.Read()) { $rows++ }
    $fetchTime = ($stopwatch.Elapsed.TotalSeconds - $connectTime - $executeTime)

    $reader.Close()
} catch {
    Write-Error "Error during query execution: $_"
} finally {
    $conn.Close()
    $stopwatch.Stop()
}

# Output metrics
Write-Host "Rows fetched: $rows"
Write-Host "Connect Time: $([math]::Round($connectTime,2)) sec"
Write-Host "Execute Time: $([math]::Round($executeTime,2)) sec"
Write-Host "Fetch Time: $([math]::Round($fetchTime,2)) sec"
Write-Host "Total Time: $([math]::Round($stopwatch.Elapsed.TotalSeconds,2)) sec"

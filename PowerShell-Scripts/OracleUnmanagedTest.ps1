# ==========================
# CONFIGURATION VARIABLES # ODP.NET Unmanaged Driver 
# https://www.oracle.com/database/technologies/appdev/ocmt.html
# ==========================
$DbHost          = "HOST"
$Port            = 1521
$ServiceName     = "SERVICE_NAME"
$UserName        = "OracleUser"
$Password        = "PW"   # Use Get-Credential in production
$CustomFetchSize = ""     # In bytes (default 131072); empty will use registry value
$SqlQuery        = "SELECT * FROM FACTSALES <= 1000000"
# ==========================

# FETCHSIZE
$RegistryPath     = "HKLM:\SOFTWARE\Oracle\ODP.NET\4.122.19.1"
$DefaultFetchSize = 131072
$FetchSizeBytes   = $DefaultFetchSize
if ($CustomFetchSize -and $CustomFetchSize -match '^\d+$') {
    $FetchSizeBytes = [int]$CustomFetchSize
    $FetchSizeMB = [math]::Round($FetchSizeBytes / 1MB, 2)
    Write-Host "Using custom FetchSize: $FetchSizeMB MB"
} else {
    try {
        $regValue = Get-ItemPropertyValue -Path $RegistryPath -Name "FetchSize"
        if ($regValue -and $regValue -match '^\d+$') {
            $FetchSizeBytes = [int]$regValue
        }
    } catch {}
    $FetchSizeMB = [math]::Round($FetchSizeBytes / 1MB, 2)
    Write-Host "Using FetchSize: $FetchSizeMB MB"
}

#Connection
$connStr = "User Id=$UserName;Password=$Password;Data Source=(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=$DbHost)(PORT=$Port))(CONNECT_DATA=(SERVICE_NAME=$ServiceName)))"
try {
    $conn = [System.Data.Common.DbProviderFactories]::GetFactory("Oracle.DataAccess.Client").CreateConnection()
    $conn.ConnectionString = $connStr
} catch {
    Write-Error "Failed to create Oracle connection: $_"
    exit 1
}

#Query Execution
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
try {
    $conn.Open()
    $connectTime = $stopwatch.Elapsed.TotalSeconds
    $cmd = $conn.CreateCommand()
    $cmd.CommandText = $SqlQuery
    $reader = $cmd.ExecuteReader()
    $executeTime = ($stopwatch.Elapsed.TotalSeconds - $connectTime)
    try { $reader.FetchSize = $FetchSizeBytes } catch {}
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

#Metrics
Write-Host "Rows fetched: $rows"
Write-Host "Connect Time: $([math]::Round($connectTime,2)) sec"
Write-Host "Execute Time: $([math]::Round($executeTime,2)) sec"
Write-Host "Fetch Time: $([math]::Round($fetchTime,2)) sec"
Write-Host "Total Time: $([math]::Round($stopwatch.Elapsed.TotalSeconds,2)) sec"

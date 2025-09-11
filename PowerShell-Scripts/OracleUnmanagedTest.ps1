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
$OutputCsv       = "c:\ms\test.csv" # Leave empty "" to skip saving
$SqlQuery        = "SELECT * FROM FACTSALES WHERE ROWNUM <= 40000"
# ==========================
# FETCHSIZE from Registry
$RegistryPath = "HKLM:\SOFTWARE\Oracle\ODP.NET\4.122.19.1"
try {
    $regValue = Get-ItemPropertyValue -Path $RegistryPath -Name "FetchSize"
    if ($regValue -and $regValue -match '^\d+$') {
        $FetchSizeMB = [math]::Round([int]$regValue / 1MB, 2)
        Write-Host "Registry FetchSize: $FetchSizeMB MB"
    }
} catch {}

# Connection String with pooling
$connStr = "User Id=$UserName;Password=$Password;Data Source=(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=$DbHost)(PORT=$Port))(CONNECT_DATA=(SERVICE_NAME=$ServiceName)))"
$connStr += ";Pooling=true;Min Pool Size=1;Max Pool Size=50;Connection Lifetime=120"

try {
    $conn = [System.Data.Common.DbProviderFactories]::GetFactory("Oracle.DataAccess.Client").CreateConnection()
    $conn.ConnectionString = $connStr
} catch {
    Write-Error "Failed to create Oracle connection: $_"
    exit 1
}

# Query Execution
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
try {
    $conn.Open()
    $connectTime = $stopwatch.Elapsed.TotalSeconds

    $cmd = $conn.CreateCommand()
    $cmd.CommandText = $SqlQuery

    # Apply custom FetchSize only if provided
    if ($CustomFetchSize -and $CustomFetchSize -match '^\d+$') {
        $cmd.FetchSize = [int]$CustomFetchSize
        Write-Host "Using custom Command FetchSize: $CustomFetchSize bytes"
    }

    $reader = $cmd.ExecuteReader()

    # Set reader.FetchSize dynamically (only if RowSize > 0)
    $rowSize = $reader.RowSize
    if ($rowSize -gt 0) {
        $reader.FetchSize = $rowSize * 1000
        # No log here to avoid confusion
    }

    $executeTime = ($stopwatch.Elapsed.TotalSeconds - $connectTime)

    $rows = 0
    $data = New-Object 'System.Collections.Generic.List[object]'

    Write-Host "Executing Query ..."
    while ($reader.Read()) {
        $row = @{}
        for ($i = 0; $i -lt $reader.FieldCount; $i++) {
            $columnName = $reader.GetName($i)
            $value = $reader.GetValue($i)
            $row[$columnName] = $value
        }
        $data.Add((New-Object PSObject -Property $row))
        $rows++
    }

    $fetchTime = ($stopwatch.Elapsed.TotalSeconds - $connectTime - $executeTime)
    $reader.Close()

    # Output CSV only if path is provided
    if (![string]::IsNullOrWhiteSpace($OutputCsv)) {
        Write-Host "Saving $OutputCsv ..."
        $data | Export-Csv -Path $OutputCsv -NoTypeInformation -Encoding UTF8
    } 

} catch {
    Write-Error "Error during query execution: $_"
} finally {
    $conn.Close()
    $stopwatch.Stop()
}

# Metrics
Write-Host "=============`nTotal Rows fetched: $rows"
Write-Host "Connect Time: $([math]::Round($connectTime,2)) sec"
Write-Host "Execute Time: $([math]::Round($executeTime,2)) sec"
Write-Host "Fetch Time: $([math]::Round($fetchTime,2)) sec"
Write-Host "Total Time: $([math]::Round($stopwatch.Elapsed.TotalSeconds,2)) sec"

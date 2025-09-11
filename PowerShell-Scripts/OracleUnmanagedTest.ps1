# ==========================
# CONFIGURATION VARIABLES # ODP.NET Unmanaged Driver 
# https://www.oracle.com/database/technologies/appdev/ocmt.html
# ==========================
$DbHost          = "HOST"
$Port            = 1521
$ServiceName     = "SERVICE_NAME"
$UserName        = "OracleUser"
$Password        = "PW"   # Use Get-Credential in production
$SqlQuery    = "SELECT * FROM FACTSALES WHERE ROWNUM <= 40000"
$OutputCsv   = ""   # When ""(empty) = fast query check. Otherwise streaming mode to save .csv
# ==========================
# Build connection string
$dataSource = "(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=$DbHost)(PORT=$Port))(CONNECT_DATA=(SERVICE_NAME=$ServiceName)))"
$connStr = "User Id=$UserName;Password=$Password;Data Source=$dataSource"


# Create connection via DbProviderFactories
$factory = [System.Data.Common.DbProviderFactories]::GetFactory("Oracle.DataAccess.Client")
$conn = $factory.CreateConnection()
$conn.ConnectionString = $connStr

# FetchSize from Registry
$RegistryPath = "HKLM:\SOFTWARE\Oracle\ODP.NET\4.122.19.1"
try {
    $regValue = Get-ItemPropertyValue -Path $RegistryPath -Name "FetchSize"
    if ($regValue -and $regValue -match '^\d+$') {
        $FetchSizeMB = [math]::Round([int]$regValue / 1MB, 2)
        Write-Host "Regedit Oracle FetchSize: $FetchSizeMB MB"
    }
} catch {}

# Run
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
$rows = 0
$connectTime = $executeTime = $fetchTime = 0

try {
    $conn.Open()
    $connectTime = $stopwatch.Elapsed.TotalSeconds

    $cmd = $conn.CreateCommand()
    $cmd.CommandText = $SqlQuery
    $reader = $cmd.ExecuteReader()
    $executeTime = $stopwatch.Elapsed.TotalSeconds - $connectTime

    $fetchStart = $stopwatch.Elapsed.TotalSeconds

    if ([string]::IsNullOrWhiteSpace($OutputCsv)) {
        # FAST MODE: just count rows
        while ($reader.Read()) { $rows++ }
    }
    else {
        # STREAMING CSV MODE
        $sw = [System.IO.StreamWriter]::new($OutputCsv, $false, [System.Text.UTF8Encoding]::new($true))
        $fieldCount = $reader.FieldCount
        $headers = (0..($fieldCount-1) | ForEach-Object { $reader.GetName($_) })
        $sw.WriteLine(($headers -join ','))

        $values = New-Object object[] $fieldCount
        while ($reader.Read()) {
            $reader.GetValues($values) | Out-Null
            $line = ($values | ForEach-Object {
                if ($_ -eq $null -or $_ -is [System.DBNull]) { "" }
                else {
                    $s = [string]$_ -replace '"','""'
                    if ($s -match '[,"\r\n]') { '"' + $s + '"' } else { $s }
                }
            }) -join ','
            $sw.WriteLine($line)
            $rows++
            if ($rows % 5000 -eq 0) { $sw.Flush() }
        }
        $sw.Close()
    }

    $fetchTime = $stopwatch.Elapsed.TotalSeconds - $fetchStart
    $reader.Close()
}
catch {
    Write-Error $_
}
finally {
    if ($conn) { $conn.Close() }
    $stopwatch.Stop()
}

# Metrics
Write-Host "==============================="
Write-Host "Rows: $rows"
Write-Host "Open Connection: $([math]::Round($connectTime,2)) sec"
Write-Host "Query Start: $([math]::Round($executeTime,2)) sec"
Write-Host "Data Retrieval:   $([math]::Round($fetchTime,2)) sec"
Write-Host "Total Elapsed Time:   $([math]::Round($stopwatch.Elapsed.TotalSeconds,2)) sec"
if ($OutputCsv) { Write-Host "CSV: $OutputCsv" }
Write-Host "==============================="

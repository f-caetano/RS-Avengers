<# Requires .NET Framework 3.5+
Collects Windows Event Viewer logs into a ZIP file
After runing, please remove the temporary created folder: "_WindowsEvents"
___________________________________________________________________________#>

# Runtime Variables
$Date = Get-Date
$MachineName = $env:COMPUTERNAME.ToLower()
$MonthDay = $Date.ToString("MMdd")
$RuningDir = $PSScriptRoot
$SavingDir = "$RuningDir\_WindowsEvents"
$EventFile = "$SavingDir\Event_"+$MonthDay+"_("+$MachineName+")_"
$ZipFile = "$RuningDir\WindowsEvents_"+$MonthDay+"_("+$MachineName+").zip"

$WindowsEvents = New-Object System.Diagnostics.Eventing.Reader.EventLogSession
$query = "*[System[TimeCreated[timediff(@SystemTime) < 604800000]]]"

# Create temporary working folder "_WindowsEvents"
Write-Host "Running... `n" -NoNewline -ForegroundColor Black -BackgroundColor white
if(!(Test-Path $SavingDir)) {New-Item -ItemType Directory -Force -Path $SavingDir | Out-Null}
ELSE 
{Remove-item "$SavingDir\*" -Include *.evtx}


# Extract Windows Events
Write-output "Collecting: System event logs"
$WindowsEvents.ExportLog("System","LogName",$query,$EventFile+"SYSTEM.evtx")
Write-Host "Collecting: Application event logs"
$WindowsEvents.ExportLog("Application","LogName",$query,$EventFile+"APPLICATION.evtx")
<# requires elevated/admin run
Write-Host "Collecting: Security event logs"
$WindowsEvents.ExportLog("Security","LogName",$query,$EventFile+"SECURITY.evtx")
#>
Write-Host "Collecting: Setup event logs"
$WindowsEvents.ExportLog("Setup","LogName",$query,$EventFile+"SETUP.evtx")

# .ZIP the files
if ($error.Count -eq 0)
{
if (Test-Path $ZipFile) {Remove-item $ZipFile}
Add-Type -assembly "system.io.compression.filesystem" 
[io.compression.zipfile]::CreateFromDirectory($SavingDir,$ZipFile)

Write-Host "DONE       `n" -NoNewline -ForegroundColor Black -BackgroundColor Green
Write-Host "Please share the generated file bellow:`n $ZipFile"
ii $RuningDir
}
# Comment if run on PS ISE
[void][System.Console]::ReadKey($true)


<# Requires .NET Framework 3.5+
Collects Windows Event Viewer logs into a ZIP file
After runing, please remove the temporary created folder: "_WindowsEvents"
___________________________________________________________________________#>

# 1.Runtime Variables
$Date = Get-Date
$MachineName = $env:COMPUTERNAME.ToLower()
$MonthDay = $Date.ToString("MMdd")
$RuningDir = $PSScriptRoot
$SavingDir = "$RuningDir\_WindowsEvents"
$EventFile = "$SavingDir\Event_"+$MonthDay+"_("+$MachineName+")_"
$ZipFile = "$RuningDir\WindowsEvents_"+$MonthDay+"_("+$MachineName+").zip"

$WindowsEvents = New-Object System.Diagnostics.Eventing.Reader.EventLogSession
$query = "*[System[TimeCreated[timediff(@SystemTime) < 604800000]]]"

# 2.Create temporary working folder "_WindowsEvents"
Write-Host "Running... `n" -NoNewline -ForegroundColor Black -BackgroundColor white
if(!(Test-Path $SavingDir)) {New-Item -ItemType Directory -Force -Path $SavingDir | Out-Null}
ELSE 
{Remove-item "$SavingDir\*" -Include *.evtx}


# 3.Extract Windows Events
Write-Host "Collecting: Windows System Events"
$WindowsEvents.ExportLog("System","LogName",$query,$EventFile+"SYSTEM.evtx")
Write-Host "Collecting: Windows Application Events"
$WindowsEvents.ExportLog("Application","LogName",$query,$EventFile+"APPLICATION.evtx")
Write-Host "Collecting: Windows Setup Events"
$WindowsEvents.ExportLog("Setup","LogName",$query,$EventFile+"SETUP.evtx")
<# requires elevated admin run
Write-Host "Collecting: Windows Security Events"
$WindowsEvents.ExportLog("Security","LogName",$query,$EventFile+"SECURITY.evtx")
#>

# 4.ZIP the files
if ($error.Count -eq 0)
{
if (Test-Path $ZipFile) {Remove-item $ZipFile}
Add-Type -assembly "system.io.compression.filesystem" 
[io.compression.zipfile]::CreateFromDirectory($SavingDir,$ZipFile)

Write-Host "DONE       `n" -NoNewline -ForegroundColor Black -BackgroundColor Green
Write-Host "Please share the generated file bellow:`n $ZipFile"
ii $RuningDir
}
# 5.Comment if run on PS ISE
[void][System.Console]::ReadKey($true)


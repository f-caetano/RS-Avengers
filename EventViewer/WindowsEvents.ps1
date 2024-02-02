<# Requires .NET Framework 3.5+
Collects Windows Event Viewer logs of past X days into ZIP file
Please review contents before sharing and remove the temporary created folder: "_WindowsEvents"
___________________________________________________________________________#>
# 1.Customizable Variables
$DaysRange = 7
$IncludeSecurityEvent = 'N' # Y = Requires elevated administrator run

# 2.Runtime Variables
$MachineName = $env:COMPUTERNAME.ToLower()
$DateFormat = (Get-Date).ToString("yyyy-MM-dd")
$RuningDir = $PSScriptRoot
$SavingDir = "$RuningDir\_WindowsEvents"
$EventFile = "$SavingDir\"+$DateFormat+"_("+$MachineName+")_"
$ZipFile = "$RuningDir\WindowsEvents_"+$DateFormat+"_("+$MachineName+").zip"

$WindowsEvents = New-Object System.Diagnostics.Eventing.Reader.EventLogSession
$query = "*[System[TimeCreated[timediff(@SystemTime) < $($daysRange * 24 * 60 * 60 * 1000)]]]"
$params = @{LogName = $query; Session = $WindowsEvents}
if ($IncludeSecurityEvent -ne 'N') {
    $logNames = "System", "Application", "Setup", "Security"
}
else {
    $logNames = "System", "Application", "Setup"
}

# 3.Validate no previous export and create temporary working folder "_WindowsEvents"
$evtxFiles = Get-ChildItem -Path $SavingDir -Filter *.evtx -Recurse | Measure-Object
if ($evtxFiles.Count -gt 0) {
   Write-Error "Folder '$SavingDir' contains .EVTX files. Please delete or move them before running the script."
   Pause
   exit
}
if(!(Test-Path $SavingDir)) {New-Item -ItemType Directory -Force -Path $SavingDir | Out-Null}
Write-Host "Collecting ${DaysRange} days:         `n" -NoNewline -ForegroundColor Black -BackgroundColor white

# 4.Extract Windows Events
try {
    foreach ($logName in $logNames) {
        Write-Output "Windows $logName Events"
        $WindowsEvents.ExportLog($logName, "LogName", $query, $EventFile+"$logName.evtx", $true)
    }
}
catch {
    Write-Error $_.Exception.Message
    Pause
}

# 5.Group files into .ZIP
If (Test-Path $ZipFile) {Remove-item $ZipFile}
    Add-Type -assembly "system.io.compression.filesystem" 
    [io.compression.zipfile]::CreateFromDirectory($SavingDir,$ZipFile)
    Write-Host "Finished                   `n" -NoNewline -ForegroundColor Black -BackgroundColor Green

# End
Read-Host -Prompt "`nPress any key to exit and to open the directory:`n $ZipFile"
ii $RuningDir


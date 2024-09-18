# Script for Windows 10/11
## Comment lines on the applications for not install/upgrade. New apps can be added respecting the name or ID of WINGET SEARCH %app% 
$applications = @(
    # #### OFFICE ####
    @{ Name = "Office 365"; ID = "Microsoft.Office" },
    @{ Name = "Microsoft Teams"; ID = "Microsoft.Teams" },

    # #### Productivity Tools ####
    @{ Name = "PowerShell 7"; ID = "Microsoft.PowerShell" },
    @{ Name = "Notepad++"; ID = "Notepad++.Notepad++" },
    # Has a custom CMD to be able to select the VS windows Shell menu option
    @{ Name = "Visual Studio Code"; ID = "Microsoft.VisualStudioCode"; CMD = 'winget install --id Microsoft.VisualStudioCode --override ''/VERYSILENT /SP- /MERGETASKS="!runcode,desktopicon,addcontextmenufiles,addcontextmenufolders,associatewithfiles,addtopath"''' },
    @{ Name = "Sysinternals Suite" },
    @{ Name = "KeePass"; ID = "DominikReichl.KeePass" },
    @{ Name = "Microsoft Remote Desktop" },
    @{ Name = "7-Zip"; ID = "7zip.7zip" },

    # #### BI Tools ####
    @{ Name = "SSMS"; ID = "Microsoft.SQLServerManagementStudio" },
    @{ Name = "Power BI Desktop" }, # Store Version
    @{ Name = "Microsoft PowerBI Desktop"; ID = "Microsoft.PowerBI" }, # Standalone Version
    @{ Name = "DAX Studio"; ID = "DaxStudio.DaxStudio" },
    @{ Name = "Power BI Report Builder" }, # Store Version

    # #### Misc Tools ####
    @{ Name = "Microsoft PowerToys" },
    @{ Name = "Screen2Gif"; ID = "NickeManarin.ScreenToGif" },

    # #### SQL Server #### (not installing by default)
    # @{ Name = "Microsoft SQL Server 2022 Developer"; CMD = "winget install '$($applications.Name)' --override '/IAcceptSqlServerLicenseTerms /Quiet /Action=Install'" },

    # #### Network Tools ####
    @{ Name = "Fiddler"; ID = "Telerik.Fiddler.Classic" },
    @{ Name = "Wireshark"; ID = "WiresharkFoundation.Wireshark" },
    @{ Name = "Microsoft Network Monitor"; ID = "Microsoft.NetMon" }
)
################
# Log Directory
$logFile = "c:\temp\Winget_InstallScript.log"
# Clear previous log
Clear-Content -Path $logFile -ErrorAction SilentlyContinue

# Log Messages with a timestamp
function Log-Message {
    param (
        [string]$message
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "$timestamp - $message"
    Add-Content -Path $logFile -Value $logEntry
}
# Maybe redundant but ensures latest Winget is installed
Write-Host "====== Winget on latest version ======"
$wingetUpgrade = winget upgrade winget --silent --disable-interactivity
Log-Message "Executing... $wingetUpgrade"
$wingetUpgrade
Log-Message "Finished checking Winget latest install"
Write-Host "=======================================`n"

# The CODE to Install
Write-Host "====== Installing Software ======"
Log-Message "Starting installation of software"
foreach ($app in $applications) {
    $appName = $app.Name
    $appID = $app.ID
    $appCMD = $app.CMD

    $appCommand = if ($appCMD) { $appCMD } elseif ($appID) { "winget install --id $appID --accept-package-agreements --silent" } else { "winget install '$appName' --accept-package-agreements --silent" }
    Write-Host "${appName}: Installing..." -ForegroundColor White -BackgroundColor Black
    Log-Message "${appName}: Installing"
    Log-Message "Executing command: $appCommand"
    try {
        Start-Process -FilePath "powershell" -ArgumentList "-Command $appCommand" -NoNewWindow -Wait -ErrorAction Stop
        Write-Host "${appName}: Done!`n" -ForegroundColor Green -BackgroundColor Black
        Log-Message "${appName}: Done!"
    } catch {
        Write-Host "${appName}: Failed`n" -ForegroundColor Red
        Log-Message "${appName}: Failed - $_"
    }
}

Log-Message "Script execution finished"
Read-Host -Prompt "`nFinished. Enter to exit"
# Script for Windows 10/11
## Comment lines on the applications for not install/upgrade. New apps can be added respecting the name or ID of WINGET SEARCH %app% 
$applications = @(
    # #### OFFICE ####
    @{Name="Office 365"; ID="Microsoft.Office"},
    @{Name="Microsoft Teams"; ID="Microsoft.Teams"},

    # #### Productivity Tools ####
    @{Name="PowerShell 7"; ID="Microsoft.PowerShell"},
    @{Name="Notepad++"; ID="Notepad++.Notepad++"},
#Custom CMD for VS to have the Windows Shell menu options enabled 
   @{Name="Visual Studio Code"; ID="Microsoft.VisualStudioCode"; CMD='winget install --id Microsoft.VisualStudioCode --override ''/VERYSILENT /SP- /MERGETASKS="!runcode,desktopicon,addcontextmenufiles,addcontextmenufolders,associatewithfiles,addtopath"''' },
    @{Name="Sysinternals Suite"},
    @{Name="KeePass"; ID="DominikReichl.KeePass"},
    @{Name="Remote Desktop"; ID="Microsoft.RemoteDesktopClient"},
    @{Name="7-Zip"; ID="7zip.7zip"},

    # #### BI Tools ####
    @{Name="SSMS"; ID="Microsoft.SQLServerManagementStudio"},
    @{Name="Power BI Desktop"}, 
    @{Name="Power BI Desktop (Standalone version)"; ID="Microsoft.PowerBI"},
    @{Name="DAX Studio"; ID="DaxStudio.DaxStudio"},
    @{Name="Power BI Report Builder"},

    # #### Misc Tools ####
    @{Name="Microsoft PowerToys"},
    @{Name="Screen2Gif"; ID="NickeManarin.ScreenToGif"},

    # #### SQL Server #### 
    #(Commented to prevent installation by default; remove # to enable)
    #@{Name="Microsoft SQL Server 2022 Developer"; CMD="winget install 'Microsoft SQL Server 2022 Developer' --accept-package-agreements --override '/IAcceptSqlServerLicenseTerms /Quiet /Action=Install'"},

    # #### Network Tools ####
    @{Name="Fiddler"; ID="Telerik.Fiddler.Classic"},
    @{Name="Bruno"; ID="Bruno.Bruno"},
    @{Name="Wireshark"; ID="WiresharkFoundation.Wireshark"},
    #Wireshark Note: NCAP doesn't support Winget. Go to https://npcap.com/#download
    @{Name="Microsoft Network Monitor"; ID="Microsoft.NetMon"}
)

# Log Directory
$logFile="c:\temp\Winget_InstallScript.log"
# Clear previous log
Clear-Content -Path $logFile -ErrorAction SilentlyContinue

# Log Messages with a timestamp
function Log-Message {
    param (
        [string]$message
    )
    $timestamp=Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry="$timestamp - $message"
    Add-Content -Path $logFile -Value $logEntry
}

# Ensure the latest Winget is installed
Write-Host "====== Checking for the latest version of Winget ======"
$wingetUpgrade=winget upgrade winget --silent --disable-interactivity
Log-Message "Executing... $wingetUpgrade"
$wingetUpgrade
Log-Message "Finished checking Winget latest install"
Write-Host "=======================================`n"

# The CODE to Install
Write-Host "====== Installing Software ======"
Log-Message "Starting installation of software"

foreach ($app in $applications) {
    $appName=$app.Name
    $appID=$app.ID
    $appCMD=$app.CMD
    # Execute based on the first non-null variable: CMD>ID>Name
    if ($appCMD) {
        $appCommand=$appCMD
    } elseif ($appID) {
        $appCommand="winget install --id $appID --accept-package-agreements --accept-source-agreements --silent --disable-interactivity"
    } else {
        $appCommand="winget install '$appName' --accept-package-agreements --accept-source-agreements --silent --disable-interactivity"
    }
    Write-Host "${appName}: Installing..." -ForegroundColor White -BackgroundColor Black
    Log-Message "${appName}: Installing"
    Log-Message "Executing command: $appCommand"
    try {
        Invoke-Expression $appCommand
        Write-Host "${appName}: Done!`n" -ForegroundColor Green -BackgroundColor Black
        Log-Message "${appName}: Done!"
    } catch {
        Write-Host "${appName}: Failed`n" -ForegroundColor Red
        Log-Message "${appName}: Failed - $_"
    }
}
Log-Message "Script execution finished"
Read-Host -Prompt "`nFinished. Enter to exit"
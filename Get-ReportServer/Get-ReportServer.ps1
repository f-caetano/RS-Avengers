## ===============================================================================================================================
#  The following script is designed to collect information that will help Microsoft Customer Support Services (CSS) troubleshoot
#
#  Microsoft CSS provides a secure file transfer to upload the generated files as they are not automatically sent to Microsoft 
#  Please discuss any concerns you may have with your support professional. Thank you
## ===============================================================================================================================

# Runtime Variables
$Date = Get-Date
$Days = 5
$MachineName = $env:COMPUTERNAME.ToLower()
$MonthDay = $Date.ToString("MMdd")
$RuningDir = "$PSScriptRoot"
$SavingDir = "$RuningDir\_Get-ReportServer"
$RSFile = "$SavingDir\ReportServer_"+$MonthDay+"_("+$MachineName+").txt"
$ServerInfo = "$SavingDir\Info_"+$MonthDay+"_("+$MachineName+").txt"
$EventFile = "$SavingDir\Event_"+$MonthDay+"_("+$MachineName+")_"
$ZipFile = "$RuningDir\ReportServer_"+$MonthDay+"_("+$MachineName+").zip"
$DaysMilliseconds = $Days * 86400000
$WindowsEvents = New-Object System.Diagnostics.Eventing.Reader.EventLogSession
$query = "*[System[TimeCreated[timediff(@SystemTime) < "+$DaysMilliseconds+"]]]"
$ConfigModeOnly = 0

# Function to allow run in ISE or PS.EXE
Function Pause ($Message = "`n`nPress any key to exit . . .") {
    if ((Test-Path variable:psISE) -and $psISE) {
        $Shell = New-Object -ComObject "WScript.Shell"
        $Button = $Shell.Popup("Press OK to continue . . .", 0, "Script end/pause", 0)
    }
    else {     
        Write-Host -NoNewline $Message
        [void][System.Console]::ReadKey($true)
        Write-Host
	}
}

Function Get-RSInstances
    {
        Param (
            [string]$InstanceName
        
        )
        $ReportingWMIInstances = @()
        $ReportingWMIInstances += Get-WmiObject -Namespace "Root\Microsoft\SqlServer\ReportServer" -Class "__Namespace" -ErrorAction 0

        if ($ReportingWMIInstances.count -lt 1)
            {
                Write-Error "Couldn't find any Report Server instances installed on this machine"
                Write-Warning  "No Report Server Instances detected. Make sure the script is executed on the correct machine"
                Write-Host  "_____________________________________________________________________________________________________"-ForegroundColor yellow -BackgroundColor Black
                Pause
                break; 
            }
        $ReportingInstances = @()

        Foreach ($ReportingWMIInstance in $ReportingWMIInstances)
            {
                # Find the RS Version and admin instance
                $WMIInstanceName = $ReportingWMIInstance.Name
                # WMIInstanceName will be in the format "RS_InstanceName", using replace
                $InstanceDisplayName = $WMIInstanceName.Replace("RS_","")
				# WMI Variables
                $InstanceNameSpace = "Root\Microsoft\SqlServer\ReportServer\$WMIInstanceName"
                $VersionInstance = Get-WmiObject -Namespace $InstanceNameSpace -Class "__Namespace" -ErrorAction 0
                $VersionInstanceName = $VersionInstance.Name
                $AdminNameSpace = "Root\Microsoft\SqlServer\ReportServer\$WMIInstanceName\$VersionInstanceName\Admin"
                $ConfigSetting = Get-WmiObject -Namespace $AdminNameSpace -Class "MSReportServer_ConfigurationSetting" | where {$_.InstanceName -eq $InstanceDisplayName}
                $ConfigSetting | add-member -MemberType NoteProperty -Name "InstanceAdminNameSpace" -Value $AdminNameSpace
                [xml]$ReportServerInstanceConfig = Get-content $ConfigSetting.PathName
                $ConfigSetting | add-member -MemberType NoteProperty -Name "ConfigFileSettings" -Value $ReportServerInstanceConfig
                $ReportingInstances += $ConfigSetting
                
            }

            if ($InstanceName)
               {
                    $ReportingInstances = $ReportingInstances | where {$_.InstanceName -like $InstanceName}
               }
        $ReportingInstances
    }

Function Get-ServerInfo {
$local:computer = $env:computername
# Main data hash to be populated later
$data = @{}
$data.'Computer' = $local:computer

# DNS lookup with a .NET class method
$ErrorActionPreference = 'SilentlyContinue'
if ( $local:proxy = [System.Net.WebProxy]::GetDefaultProxy()| foreach { $_.address } ) {
    
    $data.'Proxy ' = ($local:proxy -join ', ')
    
}

else {
    $data.'Proxy ' = 'N/A'
}
$ErrorActionPreference = 'Continue'
    # Geral info from the ComputerSystem
    if ($local:wmi = Get-WmiObject -Computer $local:computer -Class Win32_ComputerSystem -ErrorAction SilentlyContinue) {
        
        $data.'Domain'                         = $local:computer.Domain
        $data.'Computer Hardware Manufacturer' = $local:wmi.Manufacturer
        $data.'Computer Hardware Model'        = $local:wmi.Model
        $data.'Physical Memory in MB'          = ($local:wmi.TotalPhysicalMemory/1MB).ToString('N')
        $data.'Logged On User'                 = $local:wmi.Username
        $data.'Logged On User DNS'             = $local:wmi.DNSHostName
        
    }
    
    $local:wmi = $null
    
    # Disk space: free/total (DriveType 3)
    if ($local:wmi = Get-WmiObject -Computer $local:computer -Class Win32_LogicalDisk -Filter 'DriveType=3' -ErrorAction SilentlyContinue) {
        
        $local:wmi | Select 'DeviceID', 'Size', 'FreeSpace' | Foreach {
            
            $data."Local disk $($_.DeviceID)" = ('Free MB: ' + ($_.FreeSpace/1MB).ToString('N') + [char]9 + '|| Total Space: ' + ($_.Size/1MB).ToString('N'))
        }
        
    }
    
    $local:wmi = $null
    
    # IP addresses from local network adapters
    if ($local:wmi = Get-WmiObject -Computer $local:computer -Class Win32_NetworkAdapterConfiguration -ErrorAction SilentlyContinue) {
        
        $local:Ips = @{}
        
        $local:wmi | Where { $_.IPAddress -match '\S+' } | Foreach { $local:Ips.$($_.IPAddress -join ', ') = $_.MACAddress }
        
        $local:counter = 0
        $local:Ips.GetEnumerator() | Foreach {
            
            $local:counter++; $data."IP Address $local:counter" = '' + $_.Name + ' (MAC: ' + $_.Value + ')'
            
        }
        
    }
    
    $local:wmi = $null
    
    # CPU information
    if ($local:wmi = Get-WmiObject -Computer $local:computer -Class Win32_Processor -ErrorAction SilentlyContinue) {
        
        $local:wmi | Foreach {
            
            $local:maxClockSpeed     =  $_.MaxClockSpeed
            $local:numberOfCores     += $_.NumberOfCores
            $local:description       =  $_.Description
            $local:numberOfLogProc   += $_.NumberOfLogicalProcessors
            $local:socketDesignation =  $_.SocketDesignation
            $local:status            =  $_.Status
            $local:name              =  $_.Name
            
        }
        
        $data.'CPU Clock Speed'        = $local:maxClockSpeed
        $data.'CPU Cores'              = $local:numberOfCores
        $data.'CPU Description'        = $local:description
        $data.'CPU Logical Processors' = $local:numberOfLogProc
        $data.'CPU Socket'             = $local:socketDesignation
        $data.'CPU Status'             = $local:status
        $data.'CPU Name'               = $local:name -replace '\s+', ' '
        
    }
    $local:wmi = $null
    
    # Simple OS info
    if ($local:wmi = Get-WmiObject -Computer $local:computer -Class Win32_OperatingSystem -ErrorAction SilentlyContinue) {
        
        $data.'Time Local'    = $local:wmi.ConvertToDateTime($local:wmi.LocalDateTime)
        $data.'Time Zone'     = $local:wmi.CurrentTimezone
        $data.'Time Last Boot'     = $local:wmi.ConvertToDateTime($local:wmi.LastBootUpTime)
        $data.'OS System Drive'  = $local:wmi.SystemDrive
        $data.'OS Version'       = $local:wmi.Version
        $data.'OS Windows dir'   = $local:wmi.WindowsDirectory
        $data.'OS Name'          = $local:wmi.Caption
        $data.'OS Service Pack'  = [string]$local:wmi.ServicePackMajorVersion + '.' + $local:wmi.ServicePackMinorVersion
        $data.'OS Organization'  = $local:wmi.Organization
        $data.'Physical Memory Free MB' = ($local:wmi.FreePhysicalMemory/1KB).ToString('N')   
    }

     # Processes of SQL Microsoft Services
    if ($local:wmi = Get-WmiObject -Computer $local:computer -Class Win32_Service -ErrorAction SilentlyContinue) {
        $local:Service = @{}
        
       $local:wmi | where { $_.name | Select-String -Pattern "SQL" ,"report"} |Foreach { $local:Service.$($_.Name -join ', ') = $_.State}
        
        $local:counter = 0
        $local:Service.GetEnumerator() | Foreach {
            
            $local:counter++; $data."Process $local:counter" += '' + $_.Name +' (State: ' + $_.Value +')'
        
    }
    }
    
# Final Get-ServerInfo Table
$data.GetEnumerator() | Sort-Object 'Name' | Format-Table -AutoSize | Out-String -Stream | where {$_} | foreach { $_.TrimEnd()}
}
Write-Host "Running... `n" -NoNewline -ForegroundColor Black -BackgroundColor white
# Create temporary working folder "_Get-ReportServer"
if(!(Test-Path $SavingDir)) {New-Item -ItemType Directory -Force -Path $SavingDir | Out-Null}

# Run both functions
try
{
Write-Host "Collecting: Report Server WMI Information"
Get-ServerInfo | Out-File -FilePath $ServerInfo -Width 512
Get-RSInstances | Format-List -Property PSComputerName,InstanceName,Version,PathName,Database*,IsInitialized,IsReportManagerEnabled,IsSharePointIntegrated,*Service*,*Directory*,Secure*,Send*,SMTP*,FileShareAccount,UnattendedExecutionAccount,InstallationID,MachineAccountIdentity | Out-File -FilePath $RSFile
}
Catch
{
Write-Warning $Error[0]
Write-Host 
Write-Warning "Verify if the script is runned with Administrator rights"
Pause
}

# Get Report Server configuration files
Try
{
Write-Host "Collecting: Report Server Configuration and LogFiles"
Get-RSInstances | ForEach-Object {
$Instance = $_.InstanceName
$ConfigSource = (Get-Item $_.PathName).DirectoryName
$ConfigDestination = "$SavingDir\$Instance"
$LogFilesDestination = "$ConfigDestination\LogFiles"
$RSInstallDir = ((Get-Item $_.PathName).DirectoryName).TrimEnd("ReportServer")
# Create Instance Folder
if(!(Test-Path $ConfigDestination))
{New-Item -ItemType Directory -Force -Path $ConfigDestination | Out-Null}
# Create LogFiles Folder
if(!(Test-Path $LogFilesDestination) and $ConfigModeOnly -ne 1))
{New-Item -ItemType Directory -Force -Path $LogFilesDestination | Out-Null}

# Copy configuration files to ConfigDestination
Copy-Item -Path "$ConfigSource\*" -Include "*.config" -Destination $ConfigDestination -Force
If($ConfigModeOnly -ne 1)
{ Get-ChildItem -Path $RSInstallDir"LogFiles\*" -Include "*.log" | Where-Object {$_.lastwritetime -gt ($Date).AddDays(-$Days)} | Copy-Item -Destination $LogFilesDestination -Force
}

If($Instance -eq "PBIRS")
{
# Copy PBI RS Specific files
Copy-Item -Path $RSInstallDir"ASEngine\*" -Include msmdsrv.exe.config, msmdsrv.ini -Destination $ConfigDestination -Force
Copy-Item -Path $RSInstallDir"RSHostingService\*" -Include config.json -Destination $ConfigDestination -Force
If($ConfigModeOnly -ne 1)
{Copy-Item -Path $RSInstallDir"LogFiles\*" -Include ª.trc, msmdsrv.log -Destination $LogFilesDestination -Force}

Get-ChildItem -Path "$ConfigDestination\*" -Include config.json -Exclude *$MachineName* | Move-Item -Destination {$_.FullName.Replace(".json","_($MachineName).json")} -force
Get-ChildItem -Path "$ConfigDestination\*" -Include msmdsrv.ini -Exclude *$MachineName* | Move-Item -Destination {$_.FullName.Replace(".ini","_($MachineName).ini")} -force
}

# Rename the copied files to include MachineName
Get-ChildItem -Path "$ConfigDestination\*" -Include *.config -Exclude *$MachineName* | Move-Item -Destination {$_.FullName.Replace(".config","_($MachineName).config")} -force
}
}
Catch
{
Write-Warning "Failed to collect Report Server configuration files"
Write-Warning $Error[0]
Pause
}
If($ConfigModeOnly -ne 1)
# Get Windows Event Logs (Last $Days only)
{Remove-item "$SavingDir\*" -Include *.evtx
# Extract Windows Events
Write-Host "Collecting: Windows System Events"
$WindowsEvents.ExportLog("System","LogName",$query,$EventFile+"SYSTEM.evtx")
Write-Host "Collecting: Windows Application Events"
$WindowsEvents.ExportLog("Application","LogName",$query,$EventFile+"APPLICATION.evtx")
Write-Host "Collecting: Windows Setup Events"
$WindowsEvents.ExportLog("Setup","LogName",$query,$EventFile+"SETUP.evtx")
}
if ($error.Count -eq 0)
{
if (Test-Path $ZipFile) {Remove-item $ZipFile}
# .ZIP the files (.NET 4+)
Add-Type -assembly "system.io.compression.filesystem" 
[io.compression.zipfile]::CreateFromDirectory($SavingDir,$ZipFile)

Write-Host "DONE       `n           " -ForegroundColor Black -BackgroundColor Green
Write-Host "Please share the generated file bellow:`n $ZipFile"
ii $RuningDir
Pause
#v-ficaet 1.6
}

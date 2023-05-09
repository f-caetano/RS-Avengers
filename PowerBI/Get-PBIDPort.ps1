# Power BI Desktop Port 
Get-NetTCPConnection | Where-Object -Property OwningProcess -in (Get-WmiObject Win32_Process -Filter "CommandLine LIKE '%Desktop%' and Name ='msmdsrv.exe'").ProcessId | Where-Object -Property LocalAddress -eq '127.0.0.1' | select-Object Local*,OwningProcess,@{Name="Path";Expression={(Get-Process -Id $_.OwningProcess).Path}}

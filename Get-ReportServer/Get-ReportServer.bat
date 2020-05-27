@echo off
Set PATH=%~dp0
SET PSScript=%PATH%Get-ReportServer.ps1
Set PS=%SYSTEMROOT%\System32\WindowsPowerShell\v1.0\"

IF EXIST "%PATH%Get-ReportServer.ps_1" (
ren "%PATH%Get-ReportServer.ps_1" "Get-ReportServer.ps1"
)
cd %PS%
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "& {Start-Process PowerShell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File ""%PSScript%""' -Verb RunAs}"


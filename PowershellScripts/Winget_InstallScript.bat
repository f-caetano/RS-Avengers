@echo off
Set PATH=%~dp0
SET PSScript=%PATH%Winget_InstallScript.ps1
Set PS=%SYSTEMROOT%\System32\WindowsPowerShell\v1.0\"

cd %PS%
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "& {Start-Process PowerShell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File ""%PSScript%""' -Verb RunAs}"

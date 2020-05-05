@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "& {Start-Process PowerShell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File ""%~dp0\TLSClientCheck.ps1""' -Verb RunAs}"
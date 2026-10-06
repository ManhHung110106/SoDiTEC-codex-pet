@echo off
setlocal
title SodiWorm Installer
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0install.ps1"
set "SODIWORM_RESULT=%ERRORLEVEL%"
if /I not "%~1"=="--no-pause" pause
exit /b %SODIWORM_RESULT%

@echo off
title Suji Korean App
cd /d "%~dp0"
start "Suji server" /min python -m http.server 8877
timeout /t 2 /nobreak >nul
start "" http://localhost:8877/index.html
echo Suji is live at http://localhost:8877
echo A minimized 'Suji server' window keeps her running - close it when you're done studying.
timeout /t 6 >nul

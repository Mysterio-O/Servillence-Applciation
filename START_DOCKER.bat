@echo off
REM Docker Starter - Using confirmed installation path
REM This script starts Docker Desktop for SurveilWin testing

echo.
echo ========================================
echo  Starting Docker Desktop...
echo ========================================
echo.

REM Start Docker using the confirmed installation path
set DOCKER_EXE=C:\Program Files\Docker\Docker\Docker.exe

if exist "%DOCKER_EXE%" (
    echo ✓ Docker found at: %DOCKER_EXE%
    echo.
    start "" "%DOCKER_EXE%"
    echo Docker is starting...
    echo Please wait 30-60 seconds for Docker icon to appear in system tray
    echo (Look at bottom right of your screen)
    echo.
    timeout /t 60
    echo.
    echo ✓ Docker should now be running!
    echo.
    echo Next step: Open PowerShell and run:
    echo cd "C:\Users\skrab\Downloads\surveil-win\surveil-win"
    echo bash test-services.sh
    echo.
) else (
    echo ❌ Docker not found at expected location
    echo Tried: %DOCKER_EXE%
    echo Please check Docker is installed properly
    timeout /t 5
)

pause

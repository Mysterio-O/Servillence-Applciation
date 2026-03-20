#!/usr/bin/env powershell
# Docker Starter Script for SurveilWin
# This script intelligently finds and starts Docker

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  SurveilWin - Docker Starter" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

# Function to find Docker
function Find-Docker {
    $paths = @(
        "C:\Program Files\Docker\Docker\Docker.exe",
        "C:\Program Files\Docker Desktop\Docker.exe",
        "C:\ProgramData\DockerDesktop\Docker.exe",
        "C:\docker\Docker.exe"
    )

    foreach ($path in $paths) {
        if (Test-Path $path) {
            Write-Host "✓ Found Docker at: $path" -ForegroundColor Green
            return $path
        }
    }

    return $null
}

# Find Docker
$dockerPath = Find-Docker

if ($null -eq $dockerPath) {
    Write-Host "❌ ERROR: Docker not found!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Possible solutions:" -ForegroundColor Yellow
    Write-Host "1. Docker might not be installed"
    Write-Host "2. Check: C:\Program Files\Docker"
    Write-Host "3. Download: https://www.docker.com/products/docker-desktop"
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""
Write-Host "Starting Docker Desktop..." -ForegroundColor Cyan
Write-Host ""

# Start Docker
try {
    Start-Process -FilePath $dockerPath -ErrorAction Stop | Out-Null
    Write-Host "✓ Docker process started" -ForegroundColor Green
} catch {
    Write-Host "❌ Failed to start Docker: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Waiting for Docker to initialize..." -ForegroundColor Cyan
Write-Host "This may take 30-60 seconds..." -ForegroundColor Cyan
Write-Host ""

# Wait for Docker to be ready
$dockerReady = $false
$attempts = 0
$maxAttempts = 60

while ($attempts -lt $maxAttempts -and -not $dockerReady) {
    $attempts++

    try {
        $output = & "$($dockerPath | Split-Path -Parent)\docker.exe" ps -ErrorAction SilentlyContinue
        if ($?) {
            $dockerReady = $true
            Write-Host "✓ Docker is ready!" -ForegroundColor Green
            break
        }
    } catch {
        # Docker not ready yet, continue waiting
    }

    Write-Host "  Waiting... ($attempts/60 seconds)" -ForegroundColor Yellow
    Start-Sleep -Seconds 1
}

if ($dockerReady) {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "  ✅ Docker Started Successfully!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "1. Open PowerShell" -ForegroundColor White
    Write-Host "2. Go to project folder:" -ForegroundColor White
    Write-Host "   cd 'C:\Users\skrab\Downloads\surveil-win\surveil-win'" -ForegroundColor Yellow
    Write-Host "3. Run:" -ForegroundColor White
    Write-Host "   bash test-services.sh" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "You can close this window now." -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "⚠️  Docker didn't respond after 60 seconds" -ForegroundColor Yellow
    Write-Host "It may still be starting. Please wait a moment and check" -ForegroundColor Yellow
    Write-Host "if Docker icon appears in your system tray (bottom right)." -ForegroundColor Yellow
}

Write-Host ""
Read-Host "Press Enter to exit"

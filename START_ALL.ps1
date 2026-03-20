#!/usr/bin/env powershell
# Start Docker and run tests - Corrected version
# This runs everything automatically

$DockerPath = "C:\Program Files\Docker\Docker\Docker.exe"

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  SurveilWin - Docker & Test Launcher" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

# Check Docker exists
if (-not (Test-Path $DockerPath)) {
    Write-Host "❌ Docker not found at: $DockerPath" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please install Docker Desktop first:" -ForegroundColor Yellow
    Write-Host "https://www.docker.com/products/docker-desktop" -ForegroundColor Blue
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "✓ Docker found" -ForegroundColor Green
Write-Host "✓ Starting Docker Desktop..." -ForegroundColor Green
Write-Host ""

# Start Docker
Start-Process -FilePath $DockerPath

Write-Host "Waiting for Docker to initialize (30-60 seconds)..." -ForegroundColor Cyan
Write-Host ""

# Wait for Docker to be ready
$dockerBin = "C:\Program Files\Docker\Docker\resources\bin\docker.exe"
$ready = $false
$count = 0

while ($count -lt 120 -and -not $ready) {
    $count++
    try {
        $output = & $dockerBin ps 2>&1
        if ($LASTEXITCODE -eq 0) {
            $ready = $true
            Write-Host "✓ Docker is ready!" -ForegroundColor Green
            break
        }
    } catch {
        # Still starting
    }

    if ($count % 10 -eq 0) {
        Write-Host "  Waiting... ($count seconds)" -ForegroundColor Yellow
    }
    Start-Sleep -Milliseconds 500
}

if ($ready) {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "  Docker Started Successfully!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Now starting services..." -ForegroundColor Cyan
    Write-Host ""

    # Navigate to project and run tests
    cd "C:\Users\skrab\Downloads\surveil-win\surveil-win"
    bash test-services.sh
} else {
    Write-Host ""
    Write-Host "⚠️  Docker didn't respond after 60 seconds" -ForegroundColor Yellow
    Write-Host "Check if Docker icon appears in system tray (bottom right)" -ForegroundColor Yellow
    Write-Host ""
    Read-Host "Press Enter to exit"
}

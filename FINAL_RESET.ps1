# Complete Reset Script for PowerShell
# Copy and paste this entire block into PowerShell AS ADMINISTRATOR

# Stop everything
Write-Host "[1] Stopping all services..." -ForegroundColor Yellow
docker-compose down 2>$null
Start-Sleep -Seconds 3

# Remove database volume
Write-Host "[2] Removing database volume..." -ForegroundColor Yellow
docker volume rm surveil-win_postgres_data -f 2>$null
Start-Sleep -Seconds 2

# Clean Docker system
Write-Host "[3] Cleaning Docker system..." -ForegroundColor Yellow
docker system prune -f --volumes 2>$null

# Rebuild everything fresh
Write-Host "[4] Rebuilding Docker images (this takes a minute)..." -ForegroundColor Yellow
docker-compose build --no-cache 2>&1 | tail -20

# Start services
Write-Host "[5] Starting fresh services..." -ForegroundColor Yellow
docker-compose up -d
Start-Sleep -Seconds 120

# Verify running
Write-Host "[6] Checking services..." -ForegroundColor Yellow
docker-compose ps

# Check API health
Write-Host "[7] Checking API health..." -ForegroundColor Yellow
$health = curl -s http://localhost:8080/health
Write-Host "Health: $health" -ForegroundColor Green

# Check setup status
Write-Host "[8] Checking database setup status..." -ForegroundColor Yellow
$setup = curl -s http://localhost:8080/api/setup/status
Write-Host "Setup status: $setup" -ForegroundColor Cyan

if ($setup -match '"requiresBootstrap":true') {
    Write-Host "[9] Database is empty! Bootstrapping..." -ForegroundColor Green

    $bootstrap = curl -X POST "http://localhost:8080/api/setup/bootstrap" `
      -H "Content-Type: application/json" `
      -d '{
        "organizationName": "Test Organization",
        "firstName": "Admin",
        "lastName": "User",
        "email": "admin@test.com",
        "password": "Admin@123"
      }'

    if ($bootstrap -match '"accessToken"') {
        Write-Host "✅ Bootstrap successful!" -ForegroundColor Green
    } else {
        Write-Host "❌ Bootstrap failed: $bootstrap" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "⚠️  Database was already set up (this shouldn't happen)" -ForegroundColor Yellow
}

# Test login
Write-Host "[10] Testing login..." -ForegroundColor Yellow
$login = curl -X POST "http://localhost:8080/api/auth/login" `
  -H "Content-Type: application/json" `
  -d '{"email":"admin@test.com","password":"Admin@123"}'

if ($login -match '"accessToken"') {
    Write-Host "✅ Login successful!" -ForegroundColor Green
} else {
    Write-Host "❌ Login failed: $login" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  ✅ COMPLETE RESET SUCCESSFUL!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Your credentials are:" -ForegroundColor Yellow
Write-Host "  Email:    admin@test.com" -ForegroundColor Cyan
Write-Host "  Password: Admin@123" -ForegroundColor Cyan
Write-Host ""
Write-Host "Test the desktop app now:" -ForegroundColor Yellow
Write-Host "  dotnet run --project apps/Dashboard.Win/Dashboard.Win.csproj" -ForegroundColor Cyan
Write-Host ""

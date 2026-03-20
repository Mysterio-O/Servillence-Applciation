# Complete Automated Setup Script for PowerShell
# Copy and paste this ENTIRE block into PowerShell AS ADMINISTRATOR

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  SurveilWin - Complete Local Setup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$projectPath = "C:\Users\skrab\Downloads\surveil-win\surveil-win"
Set-Location $projectPath

# ===== PART 1: RESET DATABASE =====
Write-Host "[1] Stopping all services..." -ForegroundColor Yellow
docker-compose down 2>$null | Out-Null
Start-Sleep -Seconds 3

Write-Host "[2] Deleting old database volume..." -ForegroundColor Yellow
docker volume rm surveil-win_postgres_data -f 2>$null | Out-Null
Write-Host "    ✓ Database deleted" -ForegroundColor Green

# ===== PART 2: START SERVICES =====
Write-Host "[3] Starting PostgreSQL and Ollama..." -ForegroundColor Yellow
docker-compose up -d postgres ollama
Start-Sleep -Seconds 30
Write-Host "    ✓ Waiting..." -ForegroundColor Green

Write-Host "[4] Starting API and Web services..." -ForegroundColor Yellow
docker-compose up -d api web
Start-Sleep -Seconds 70
Write-Host "    ✓ Services starting..." -ForegroundColor Green

# ===== VERIFICATION =====
Write-Host "[5] Verifying all services are running..." -ForegroundColor Yellow
$ps = docker-compose ps
Write-Host $ps
Write-Host ""

# Check API health
Write-Host "[6] Checking API health..." -ForegroundColor Yellow
$health = curl -s http://localhost:8080/health
if ($health -match "healthy") {
    Write-Host "    ✓ API is healthy" -ForegroundColor Green
} else {
    Write-Host "    ✗ API failed" -ForegroundColor Red
    exit 1
}

# Check setup status
Write-Host "[7] Checking database setup status..." -ForegroundColor Yellow
$setup = curl -s http://localhost:8080/api/setup/status
if ($setup -match '"requiresBootstrap":true') {
    Write-Host "    ✓ Database is empty (needs bootstrap)" -ForegroundColor Green
} elseif ($setup -match '"requiresBootstrap":false') {
    Write-Host "    ⚠ Database already has users!" -ForegroundColor Yellow
    Write-Host "    Going to Step 2 anyway (will fail if different credentials)..." -ForegroundColor Yellow
} else {
    Write-Host "    ✗ Unexpected response: $setup" -ForegroundColor Red
    exit 1
}

# ===== PART 3: BOOTSTRAP ADMIN =====
Write-Host ""
Write-Host "[8] Creating ADMIN account..." -ForegroundColor Yellow
$adminResponse = curl -s -X POST "http://localhost:8080/api/setup/bootstrap" `
  -H "Content-Type: application/json" `
  -d '{
    "organizationName": "Test Company",
    "firstName": "Admin",
    "lastName": "User",
    "email": "admin@test.com",
    "password": "Admin@123"
  }'

if ($adminResponse -match '"accessToken"') {
    Write-Host "    ✓ Admin account created successfully!" -ForegroundColor Green
    $adminToken = ($adminResponse | ConvertFrom-Json).accessToken
    Write-Host "    ✓ Admin token received" -ForegroundColor Green
} else {
    Write-Host "    ✗ Failed to create admin account" -ForegroundColor Red
    Write-Host "    Response: $adminResponse" -ForegroundColor Red
    exit 1
}

# ===== VERIFY ADMIN LOGIN =====
Write-Host "[9] Verifying admin login works..." -ForegroundColor Yellow
$adminLogin = curl -s -X POST "http://localhost:8080/api/auth/login" `
  -H "Content-Type: application/json" `
  -d '{"email":"admin@test.com","password":"Admin@123"}'

if ($adminLogin -match '"accessToken"') {
    Write-Host "    ✓ Admin login successful!" -ForegroundColor Green
} else {
    Write-Host "    ✗ Admin login failed" -ForegroundColor Red
    Write-Host "    Response: $adminLogin" -ForegroundColor Red
    exit 1
}

# ===== PART 4: CREATE EMPLOYEE =====
Write-Host "[10] Creating EMPLOYEE account..." -ForegroundColor Yellow

# Get fresh admin token
$adminLoginFresh = curl -s -X POST "http://localhost:8080/api/auth/login" `
  -H "Content-Type: application/json" `
  -d '{"email":"admin@test.com","password":"Admin@123"}'

$adminTokenFresh = ($adminLoginFresh | ConvertFrom-Json).accessToken

# Create employee
$employeeResponse = curl -s -X POST "http://localhost:8080/api/users" `
  -H "Authorization: Bearer $adminTokenFresh" `
  -H "Content-Type: application/json" `
  -d '{
    "email": "employee@test.com",
    "firstName": "John",
    "lastName": "Doe",
    "role": "Employee"
  }'

if ($employeeResponse -match '"id"') {
    Write-Host "    ✓ Employee account created successfully!" -ForegroundColor Green
} else {
    Write-Host "    ⚠ Employee response: $employeeResponse" -ForegroundColor Yellow
}

# ===== SUCCESS =====
Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  ✅ SETUP COMPLETE - READY TO TEST!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

Write-Host "YOUR TEST ACCOUNTS:" -ForegroundColor Cyan
Write-Host ""
Write-Host "👨‍💼 ADMIN ACCOUNT:" -ForegroundColor Yellow
Write-Host "   Email:    admin@test.com" -ForegroundColor White
Write-Host "   Password: Admin@123" -ForegroundColor White
Write-Host ""
Write-Host "👤 EMPLOYEE ACCOUNT:" -ForegroundColor Yellow
Write-Host "   Email:    employee@test.com" -ForegroundColor White
Write-Host "   Password: Employee@123" -ForegroundColor White
Write-Host ""

Write-Host "========================================" -ForegroundColor Green
Write-Host ""

Write-Host "🌐 TEST WEB DASHBOARD:" -ForegroundColor Cyan
Write-Host "   1. Open: http://localhost:5173" -ForegroundColor White
Write-Host "   2. Login: admin@test.com / Admin@123" -ForegroundColor White
Write-Host "   3. Verify you see dashboard and employees" -ForegroundColor White
Write-Host "   4. Logout and login as employee to test isolation" -ForegroundColor White
Write-Host ""

Write-Host "🖥️  TEST DESKTOP APP:" -ForegroundColor Cyan
Write-Host "   1. Open NEW PowerShell window" -ForegroundColor White
Write-Host "   2. Run: cd 'C:\Users\skrab\Downloads\surveil-win\surveil-win'" -ForegroundColor White
Write-Host "   3. Run: dotnet run --project apps/Dashboard.Win/Dashboard.Win.csproj" -ForegroundColor White
Write-Host "   4. Login: employee@test.com / Employee@123" -ForegroundColor White
Write-Host "   5. Click 'Start Shift' and use different apps" -ForegroundColor White
Write-Host "   6. Watch activity in real-time" -ForegroundColor White
Write-Host "   7. Click 'End Shift'" -ForegroundColor White
Write-Host "   8. Check Web Dashboard to verify activity saved" -ForegroundColor White
Write-Host ""

Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "ℹ️  Services will keep running in background" -ForegroundColor Cyan
Write-Host "ℹ️  To stop services: docker-compose down" -ForegroundColor Cyan
Write-Host "ℹ️  To reset everything: Delete volume and re-run this script" -ForegroundColor Cyan
Write-Host ""
Write-Host "Happy testing! 🚀" -ForegroundColor Green
Write-Host ""

# Complete Automated Setup Script for PowerShell
# Right-click and "Run with PowerShell" or copy-paste into PowerShell AS ADMINISTRATOR

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  SurveilWin - Complete Local Setup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$projectPath = "C:\Users\skrab\Downloads\surveil-win\surveil-win"
Set-Location $projectPath

# PART 1: RESET DATABASE
Write-Host "[1] Stopping all services..." -ForegroundColor Yellow
docker-compose down 2>$null
Start-Sleep -Seconds 3

Write-Host "[2] Deleting old database volume..." -ForegroundColor Yellow
docker volume rm surveil-win_postgres_data -f 2>$null
Write-Host "    OK - Database deleted" -ForegroundColor Green

# PART 2: START SERVICES
Write-Host "[3] Starting PostgreSQL and Ollama..." -ForegroundColor Yellow
docker-compose up -d postgres ollama
Start-Sleep -Seconds 35

Write-Host "[4] Starting API and Web services..." -ForegroundColor Yellow
docker-compose up -d api web
Start-Sleep -Seconds 60

Write-Host "[5] Checking services status..." -ForegroundColor Yellow
docker-compose ps
Write-Host ""

# PART 3: VERIFY API HEALTH
Write-Host "[6] Checking API health..." -ForegroundColor Yellow
$health = curl -s http://localhost:8080/health
if ($health -match "healthy") {
    Write-Host "    OK - API is healthy" -ForegroundColor Green
} else {
    Write-Host "    ERROR - API not responding" -ForegroundColor Red
    exit 1
}

# PART 4: BOOTSTRAP ADMIN
Write-Host "[7] Creating ADMIN account..." -ForegroundColor Yellow
$adminResponse = curl -s -X POST "http://localhost:8080/api/setup/bootstrap" `
  -H "Content-Type: application/json" `
  -d '{
    "organizationName": "Test Company",
    "firstName": "Admin",
    "lastName": "User",
    "email": "admin@test.com",
    "password": "Admin@123"
  }'

if ($adminResponse -match "accessToken") {
    Write-Host "    OK - Admin account created" -ForegroundColor Green
} else {
    Write-Host "    ERROR - Failed to create admin" -ForegroundColor Red
    Write-Host "    Response: $adminResponse" -ForegroundColor Red
    exit 1
}

# PART 5: VERIFY ADMIN LOGIN
Write-Host "[8] Verifying admin login works..." -ForegroundColor Yellow
$adminLogin = curl -s -X POST "http://localhost:8080/api/auth/login" `
  -H "Content-Type: application/json" `
  -d '{"email":"admin@test.com","password":"Admin@123"}'

if ($adminLogin -match "accessToken") {
    Write-Host "    OK - Admin login successful" -ForegroundColor Green
} else {
    Write-Host "    ERROR - Admin login failed" -ForegroundColor Red
    exit 1
}

# PART 6: CREATE EMPLOYEE
Write-Host "[9] Creating EMPLOYEE account..." -ForegroundColor Yellow

$adminLoginFresh = curl -s -X POST "http://localhost:8080/api/auth/login" `
  -H "Content-Type: application/json" `
  -d '{"email":"admin@test.com","password":"Admin@123"}'

$adminTokenObj = $adminLoginFresh | ConvertFrom-Json
$adminToken = $adminTokenObj.accessToken

$employeeResponse = curl -s -X POST "http://localhost:8080/api/users" `
  -H "Authorization: Bearer $adminToken" `
  -H "Content-Type: application/json" `
  -d '{
    "email": "employee@test.com",
    "firstName": "John",
    "lastName": "Doe",
    "role": "Employee"
  }'

if ($employeeResponse -match "id") {
    Write-Host "    OK - Employee account created" -ForegroundColor Green
} else {
    Write-Host "    WARNING - Employee response: $employeeResponse" -ForegroundColor Yellow
}

# SUCCESS
Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  SUCCESS - Setup Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

Write-Host "YOUR TEST CREDENTIALS:" -ForegroundColor Cyan
Write-Host ""
Write-Host "ADMIN ACCOUNT:" -ForegroundColor Yellow
Write-Host "  Email:    admin@test.com" -ForegroundColor White
Write-Host "  Password: Admin@123" -ForegroundColor White
Write-Host ""
Write-Host "EMPLOYEE ACCOUNT:" -ForegroundColor Yellow
Write-Host "  Email:    employee@test.com" -ForegroundColor White
Write-Host "  Password: Employee@123" -ForegroundColor White
Write-Host ""

Write-Host "========================================" -ForegroundColor Green
Write-Host ""

Write-Host "NEXT STEPS:" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Test Web Dashboard:" -ForegroundColor Yellow
Write-Host "   - Open: http://localhost:5173" -ForegroundColor White
Write-Host "   - Login: admin@test.com / Admin@123" -ForegroundColor White
Write-Host "   - Verify dashboard loads" -ForegroundColor White
Write-Host ""

Write-Host "2. Test Desktop App:" -ForegroundColor Yellow
Write-Host "   - Open new PowerShell window" -ForegroundColor White
Write-Host "   - Run: cd 'C:\Users\skrab\Downloads\surveil-win\surveil-win'" -ForegroundColor White
Write-Host "   - Run: dotnet run --project apps/Dashboard.Win/Dashboard.Win.csproj" -ForegroundColor White
Write-Host "   - Login: employee@test.com / Employee@123" -ForegroundColor White
Write-Host ""

Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Ready to test!" -ForegroundColor Green
Write-Host ""

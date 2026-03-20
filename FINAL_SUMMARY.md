# 🎯 LOCAL DATABASE SETUP & TESTING - FINAL SUMMARY

## ⚡ FASTEST WAY - Copy & Paste One Script

### PowerShell - Run as ADMINISTRATOR

```powershell
# JUST COPY THE ENTIRE SCRIPT BELOW AND PASTE INTO POWERSHELL

$projectPath = "C:\Users\skrab\Downloads\surveil-win\surveil-win"
Set-Location $projectPath
docker-compose down; docker volume rm surveil-win_postgres_data -f
docker-compose up -d postgres ollama; Start-Sleep 30
docker-compose up -d api web; Start-Sleep 70
curl -X POST "http://localhost:8080/api/setup/bootstrap" -H "Content-Type: application/json" -d '{"organizationName":"Test Company","firstName":"Admin","lastName":"User","email":"admin@test.com","password":"Admin@123"}'
$LOGIN = curl -s -X POST "http://localhost:8080/api/auth/login" -H "Content-Type: application/json" -d '{"email":"admin@test.com","password":"Admin@123"}'
$TOKEN = ($LOGIN | ConvertFrom-Json).accessToken
curl -X POST "http://localhost:8080/api/users" -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" -d '{"email":"employee@test.com","firstName":"John","lastName":"Doe","role":"Employee"}'
Write-Host "✅ Setup Complete - Ready to Test!" -ForegroundColor Green
```

Or use the automated script:
```powershell
.\COMPLETE_SETUP.ps1
```

---

## 📋 Step-by-Step Manual Process

### **STEP 1: Reset Database**
```powershell
cd "C:\Users\skrab\Downloads\surveil-win\surveil-win"
docker-compose down
docker volume rm surveil-win_postgres_data -f
```

### **STEP 2: Start Services** (wait 60 seconds total)
```powershell
docker-compose up -d postgres ollama
Start-Sleep -Seconds 30
docker-compose up -d api web
Start-Sleep -Seconds 30
docker-compose ps  # Verify all containers Up
```

### **STEP 3: Bootstrap Admin**
```powershell
curl -X POST "http://localhost:8080/api/setup/bootstrap" `
  -H "Content-Type: application/json" `
  -d '{
    "organizationName": "Test Company",
    "firstName": "Admin",
    "lastName": "User",
    "email": "admin@test.com",
    "password": "Admin@123"
  }'
```
Should return: `{"accessToken":"...","refreshToken":"...","user":{...}}`

### **STEP 4: Create Employee**
```powershell
$LOGIN = curl -s -X POST "http://localhost:8080/api/auth/login" `
  -H "Content-Type: application/json" `
  -d '{"email":"admin@test.com","password":"Admin@123"}'

$TOKEN = ($LOGIN | ConvertFrom-Json).accessToken

curl -X POST "http://localhost:8080/api/users" `
  -H "Authorization: Bearer $TOKEN" `
  -H "Content-Type: application/json" `
  -d '{
    "email": "employee@test.com",
    "firstName": "John",
    "lastName": "Doe",
    "role": "Employee"
  }'
```

### **STEP 5: Test Web Dashboard**
```
Open: http://localhost:5173
Login: admin@test.com / Admin@123
✓ Should see dashboard, employees, and activity
```

### **STEP 6: Test Desktop App**
```powershell
# NEW PowerShell window
cd "C:\Users\skrab\Downloads\surveil-win\surveil-win"
dotnet run --project apps/Dashboard.Win/Dashboard.Win.csproj
# Login: employee@test.com / Employee@123
# Click "Start Shift" → Use apps → Watch monitoring → Click "End Shift"
```

---

## 🔐 Your Test Credentials

After Setup:
```
ADMIN:
  Email:    admin@test.com
  Password: Admin@123

EMPLOYEE:
  Email:    employee@test.com
  Password: Employee@123
```

---

## ✅ What to Verify After Setup

### Web Dashboard (Admin View)
- [ ] Can login with admin@test.com
- [ ] See "Employees" list
- [ ] See "Activity" or "Reports" section
- [ ] See admin settings/options
- [ ] Can see employee list (including employee@test.com)

### Web Dashboard (Employee View)
- [ ] Can logout
- [ ] Can login with employee@test.com
- [ ] See ONLY own data (no employees list)
- [ ] NO admin settings visible
- [ ] No access to other employees' data

### Desktop Application
- [ ] App launches (WPF window)
- [ ] Login works (employee@test.com / Employee@123)
- [ ] Shows "Shift" panel after login
- [ ] Can click "Start Shift"
- [ ] Monitoring panel appears
- [ ] Frame counter increments
- [ ] Current app shown (chrome, notepad, etc)
- [ ] Can click "End Shift"
- [ ] Shift panel reappears

### Real-Time Monitoring
- [ ] Open different apps while shift is active
- [ ] See app names change in monitoring panel
- [ ] Frame count increasing
- [ ] Activity visible in Web Dashboard after shift ends

---

## 📊 Database Information

```
Type:          PostgreSQL 16
Container:     surveil-win-postgres
Host:          postgres (Docker) / localhost (local)
Port:          5432
Database:      surveilwin
Username:      postgres
Password:      postgres
Connection:    Host=postgres;Database=surveilwin;Username=postgres;Password=postgres
Persist:       surveil-win_postgres_data (Docker volume)
```

---

## 🔧 Useful Commands

```powershell
# Check all services
docker-compose ps

# View API logs
docker-compose logs api

# Restart API
docker-compose restart api

# Check API health
curl http://localhost:8080/health

# Check setup status (empty DB = true)
curl http://localhost:8080/api/setup/status

# Stop everything
docker-compose down

# Delete database and start over
docker volume rm surveil-win_postgres_data -f

# View Swagger API docs
http://localhost:8080/swagger
```

---

## 🆘 Troubleshooting

| Problem | Solution |
|---------|----------|
| "Invalid email or password" | Database has old data - delete volume (Step 1) |
| Desktop app won't launch | Make sure you're in project directory, try `dotnet build` first |
| Services not starting | Wait 60 seconds, check `docker-compose ps` |
| API not responding | Check `curl http://localhost:8080/health` |
| Monitoring showing no activity | Make sure shift started, switch between apps |
| Employee can see admin data | Issue with API permissions - reset database |

---

## 📁 Reference Files Created

| File | Purpose |
|------|---------|
| `COMPLETE_SETUP.ps1` | Automated setup script |
| `LOCAL_SETUP_AND_TESTING.md` | Detailed step-by-step guide |
| `QUICK_START_LOCAL.md` | Quick reference (6 steps) |
| `QUICK_COMMANDS.sh` | Command reference |
| `COMPLETE_DATABASE_SOLUTION.md` | In-depth architecture analysis |

---

## 🎯 Testing Workflow

```
1. Run COMPLETE_SETUP.ps1
   ↓
2. Wait for "✅ SETUP COMPLETE" message
   ↓
3. Open http://localhost:5173 (Web Dashboard)
   ↓
4. Login as admin@test.com
   ↓
5. Verify admin sees all employees/activity
   ↓
6. Logout and login as employee@test.com
   ↓
7. Verify employee ONLY sees own data
   ↓
8. Open new PowerShell terminal
   ↓
9. Run: dotnet run --project apps/Dashboard.Win/Dashboard.Win.csproj
   ↓
10. Login as employee@test.com in Desktop App
    ↓
11. Click "Start Shift"
    ↓
12. Open different applications (Chrome, Word, Notepad, etc)
    ↓
13. Watch activity captured in real-time (frame count, app names)
    ↓
14. Click "End Shift"
    ↓
15. Go back to Web Dashboard (as admin)
    ↓
16. Check that activity from the shift is visible
    ↓
17. ✅ TESTING COMPLETE - System works!
```

---

## 🚀 YOU'RE READY TO GO!

Choose your approach:

**Option A: Fastest (1 command)**
```powershell
.\COMPLETE_SETUP.ps1
```

**Option B: Step-by-step (follow LOCAL_SETUP_AND_TESTING.md)**

**Option C: Quick reference (use QUICK_START_LOCAL.md)**

All three will get you to working test accounts and a fully functional local setup!

After setup, you can test the Web Dashboard and Desktop App with confidence.

---

**Pick an option above and let me know when you've completed it!** 🎉

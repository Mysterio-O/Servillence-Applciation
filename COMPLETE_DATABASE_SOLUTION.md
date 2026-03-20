# 🔍 SurveilWin Database Issue - Complete Analysis & Solution

## Current Situation

You said you connected the database to **Neon** (cloud database), but currently:
- ✅ `.env` is pointing to **LOCAL PostgreSQL** (Host=postgres)
- ✅ API is healthy and running
- ❌ Database already has users (requiresBootstrap=false)
- ❌ But credentials `admin@test.com` / `Admin@123` DON'T WORK

This means: **The database has different accounts than what we created**

---

## 🎯 Solution: We Need to Choose ONE Approach

### **OPTION 1: Use LOCAL PostgreSQL (Simpler)**

**Pros:**
- Don't need internet/cloud
- Easier to reset
- Data is local

**Cons:**
- Only works locally
- Data lost if Docker volume deleted

**Steps:**
1. Keep `.env` as is (pointing to local postgres)
2. Reset the local database completely
3. Create fresh test accounts

### **OPTION 2: Use NEON Cloud Database (Production-Ready)**

**Pros:**
- Works from anywhere
- Persistent data in cloud
- More like production

**Cons:**
- Need Neon account
- Need internet connection
- Slower than local (network latency)

**Steps:**
1. Get your actual Neon connection string
2. Update `.env` to use Neon URL
3. Connect Docker API to Neon
4. Create fresh test accounts

---

## ⚡ IMMEDIATE FIX: Complete LOCAL RESET (Option 1)

Follow these **EXACT** steps in PowerShell **AS ADMINISTRATOR**:

### **Step 1: Delete Docker volume (the database)**
```powershell
docker-compose down
docker volume rm surveil-win_postgres_data
```

### **Step 2: Verify volume is deleted**
```powershell
docker volume ls | findstr surveil-win
```
Should return NOTHING

### **Step 3: Start fresh**
```powershell
cd "C:\Users\skrab\Downloads\surveil-win\surveil-win"
docker-compose up -d postgres
Start-Sleep -Seconds 30
docker-compose up -d api web ollama
Start-Sleep -Seconds 30
```

### **Step 4: Verify API is healthy**
```powershell
curl http://localhost:8080/health
```

### **Step 5: Check database is EMPTY**
```powershell
curl http://localhost:8080/api/setup/status
```

**Must return:** `{"requiresBootstrap":true}`

If returns `false`, the database still has data. Go back to Step 1.

### **Step 6: Bootstrap admin account**
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

**Should return JSON with:**
```
"accessToken": "eyJ..."
"refreshToken": "..."
"user": { "email": "admin@test.com", "role": "SuperAdmin" }
```

### **Step 7: Verify login works**
```powershell
curl -X POST "http://localhost:8080/api/auth/login" `
  -H "Content-Type: application/json" `
  -d '{"email":"admin@test.com","password":"Admin@123"}'
```

**Should return:** accessToken (NOT "Invalid email or password")

### **Step 8: Create employee account**
```powershell
# Get admin token first
$LOGIN = curl -s -X POST "http://localhost:8080/api/auth/login" `
  -H "Content-Type: application/json" `
  -d '{"email":"admin@test.com","password":"Admin@123"}'

$TOKEN = ($LOGIN | ConvertFrom-Json).accessToken

# Create employee
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

---

## ✅ AFTER COMPLETING STEPS 1-8

You will have TWO working accounts:

```
ADMIN:
  Email:    admin@test.com
  Password: Admin@123
  Access:   All employees, all data, admin features

EMPLOYEE:
  Email:    employee@test.com
  Password: Employee@123
  Access:   Own data only, monitoring, shifts
```

---

## 🧪 TEST BOTH APPLICATIONS

### **Test 1: Web Dashboard**
```
URL: http://localhost:5173
Login: admin@test.com / Admin@123
Expected: See dashboard, employees list, activity feed
```

### **Test 2: Desktop App**
```powershell
dotnet run --project apps/Dashboard.Win/Dashboard.Win.csproj
```

Login:
```
Email:    employee@test.com
Password: Employee@123
```

Expected:
1. App launches ✅
2. Desktop login panel appears ✅
3. Click "Sign In" ✅
4. See "Shift" panel ✅
5. Click "Start Shift" ✅
6. See monitoring panel ✅
7. Activity captured in real-time ✅

---

## 🔄 IF USING NEON CLOUD INSTEAD

If you want to use your Neon database instead of local:

1. Get your Neon connection string from the Neon dashboard
   - Format: `PostgreSQL://user:password@host:5432/database?sslmode=require`

2. Update `.env`:
   ```
   DB_CONNECTION_STRING=your-neon-url-here
   ```

3. DON'T change docker-compose (still runs local postgres for testing)

4. Stop Docker, then:
   ```powershell
   docker-compose up -d api web ollama
   ```

5. The API will connect to Neon cloud automatically

6. Follow steps 4-8 above to bootstrap

---

## 🎯 WHICH SHOULD YOU USE?

**Use LOCAL (Option 1) if:**
- ✅ You're developing locally
- ✅ You want fastest performance
- ✅ You don't need persistent data
- ✅ Simpler setup

**Use NEON (Option 2) if:**
- ✅ You want persistent cloud connectivity
- ✅ Multiple developers need to share same DB
- ✅ Preparing for production
- ✅ You already have a Neon account

---

## 🚨 TROUBLESHOOTING

### "Docker volume still has data"
```powershell
docker system prune -f --volumes
docker volume prune -f
```

Then try again.

### "requiresBootstrap is still false"
```powershell
# Force stop everything
docker-compose down
# Wait 5 seconds
Start-Sleep -Seconds 5
# Double-check volume is gone
docker volume rm surveil-win_postgres_data -f
# Restart
docker-compose up -d postgres
Start-Sleep -Seconds 30
```

### "Bootstrap says already completed"
Database has users from a previous run. Delete the volume and restart (see above).

### "Login still fails after bootstrap"
```powershell
# Check the actual error
$resp = curl -s -X POST "http://localhost:8080/api/auth/login" `
  -H "Content-Type: application/json" `
  -d '{"email":"admin@test.com","password":"Admin@123"}'

Write-Host $resp -ForegroundColor Red

# If error, check setup status
curl http://localhost:8080/api/setup/status
```

---

## 📝 SUMMARY

**What we now know:**
1. Database architecture: PostgreSQL 16 with Entity Framework Core
2. Multi-tenant design with UUID keys
3. User roles: SuperAdmin, OrgAdmin, Manager, Employee
4. Database starts EMPTY - need bootstrap
5. Passwords hashed with BCrypt (strong password required)
6. Can use local OR cloud database

**What's broken:**
1. Database has old data that doesn't match our credentials
2. Need to completely reset it

**How to fix:**
1. Delete Docker volume (the database storage)
2. Restart services (creates fresh empty database)
3. Bootstrap with new credentials
4. Test both applications

---

**Ready to proceed? Follow the 8 steps above!** 🚀

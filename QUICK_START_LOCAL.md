# ⚡ QUICK START - LOCAL DATABASE & TESTING

## 📋 The 6 Essential Steps

### 1️⃣ **RESET DATABASE** (PowerShell - Admin)
```powershell
cd "C:\Users\skrab\Downloads\surveil-win\surveil-win"
docker-compose down
docker volume rm surveil-win_postgres_data -f
```

### 2️⃣ **START SERVICES**
```powershell
docker-compose up -d postgres ollama
Start-Sleep -Seconds 30
docker-compose up -d api web
Start-Sleep -Seconds 60
docker-compose ps  # Verify all Up
```

### 3️⃣ **CREATE ADMIN ACCOUNT**
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

### 4️⃣ **CREATE EMPLOYEE ACCOUNT**
```powershell
$LOGIN = curl -s -X POST "http://localhost:8080/api/auth/login" `
  -H "Content-Type: application/json" `
  -d '{"email":"admin@test.com","password":"Admin@123"}'

$TOKEN = ($LOGIN | ConvertFrom-Json).accessToken

curl -X POST "http://localhost:8080/api/users" `
  -H "Authorization: Bearer $TOKEN" `
  -H "Content-Type: application/json" `
  -d '{"email":"employee@test.com","firstName":"John","lastName":"Doe","role":"Employee"}'
```

### 5️⃣ **TEST WEB DASHBOARD**
```
Browser: http://localhost:5173
Login: admin@test.com / Admin@123
✅ Should see dashboard with employees and activity
```

### 6️⃣ **TEST DESKTOP APP**
```powershell
# NEW PowerShell terminal
cd "C:\Users\skrab\Downloads\surveil-win\surveil-win"
dotnet run --project apps/Dashboard.Win/Dashboard.Win.csproj
# Login: employee@test.com / Employee@123
# Click "Start Shift" → Use applications → Watch activity
# Click "End Shift" → Check Web Dashboard for activity
```

---

## 🎯 YOUR CREDENTIALS (After Step 4)

```
ADMIN ACCOUNT:
  Email:    admin@test.com
  Password: Admin@123

EMPLOYEE ACCOUNT:
  Email:    employee@test.com
  Password: Employee@123
```

---

## ✅ SUCCESS INDICATORS

| Step | Expected Result |
|------|-----------------|
| Step 2 | All containers show "Up" |
| Step 3 | Returns JSON with `"accessToken"` |
| Step 4 | Returns JSON with user info |
| Step 5 | Dashboard loads, shows admin features |
| Step 6 | Desktop app launches, login works, shift starts |

---

## 📊 What You'll Test

### WEB DASHBOARD (http://localhost:5173)
- ✅ **As Admin**: See all employees, activity, settings
- ✅ **As Employee**: See only own data (no admin features)
- ✅ **Data Isolation**: Employee cannot access other employees' data

### DESKTOP APP
- ✅ **Login**: Employee logs in successfully
- ✅ **Shift Management**: Start/End shifts work
- ✅ **Real-Time Monitoring**: Activity captured in real-time
  - Frame count increments
  - Current app shows
  - Activity log updates
- ✅ **Data Persistence**: Activity visible in Web Dashboard after shift ends

---

## 🔧 LOCAL DATABASE SETUP

```
Database:    PostgreSQL 16 (Docker)
Connection:  Host=postgres;Database=surveilwin;Username=postgres;Password=postgres
Port:        5432
Volume:      surveil-win_postgres_data (Docker persistent storage)
```

---

## 🚀 FULL TESTING FLOW

```
1. Reset DB (Step 1-2)
2. Create accounts (Step 3-4)
3. Test Web as Admin (Step 5)
4. Test Web as Employee (Step 5 - logout/login)
5. Test Desktop as Employee (Step 6)
6. Start shift and monitor
7. End shift
8. Check activity in Web Dashboard
```

---

## ⏱️ TIMING

| Action | Wait Time |
|--------|-----------|
| After `docker-compose down` | 3 seconds |
| After starting postgres/ollama | 30 seconds |
| After starting api/web | 60 seconds |
| After bootstrap | 0 seconds (immediate) |
| Before running desktop app | 0 seconds (immediate) |

---

## 📝 FILES REFERENCE

- `LOCAL_SETUP_AND_TESTING.md` - Detailed step-by-step guide
- `QUICK_COMMANDS.sh` - Command reference
- `COMPLETE_DATABASE_SOLUTION.md` - In-depth analysis
- `.env` - Database connection config

---

## 💡 KEY POINTS

1. **Local Database**: Uses Docker PostgreSQL, no internet needed
2. **Test Accounts**: After bootstrap, use `admin@test.com` / `Admin@123`
3. **Employee Created**: Via API using admin token
4. **Data Isolation**: Built-in at API level (employees only see own data)
5. **Monitoring**: Real-time activity capture when shift is active
6. **Reset Anytime**: Just delete the Docker volume and restart

---

**Follow the 6 steps and you're ready to test!** 🎉

# 🚀 Complete Local Setup & Testing Guide

## Part 1: RESET & CONNECT TO LOCAL DATABASE

### Step 1.1: Stop Everything & Delete Old Database
**Open PowerShell AS ADMINISTRATOR** and run:

```powershell
cd "C:\Users\skrab\Downloads\surveil-win\surveil-win"
docker-compose down
```

Wait 3 seconds, then:

```powershell
docker volume rm surveil-win_postgres_data -f
```

Verify it's deleted:
```powershell
docker volume ls | findstr surveil-win
```
Should return NOTHING

---

### Step 1.2: Verify .env is Correct for Local Database
```powershell
cat .env | Select-String "DB_CONNECTION"
```

Should show:
```
DB_CONNECTION_STRING=Host=postgres;Database=surveilwin;Username=postgres;Password=postgres
```

✅ If it shows this, you're good to proceed
❌ If it shows something else with neon.tech, fix it:

```powershell
# Edit .env - replace the DB_CONNECTION_STRING line with:
# DB_CONNECTION_STRING=Host=postgres;Database=surveilwin;Username=postgres;Password=postgres
```

---

### Step 1.3: Start Fresh Local Database
```powershell
docker-compose up -d postgres ollama
```

Wait 30 seconds for PostgreSQL to start

---

### Step 1.4: Start API & Web Services
```powershell
docker-compose up -d api web
```

Wait another 60 seconds for API to initialize

---

### Step 1.5: Verify All Services are Running
```powershell
docker-compose ps
```

Should show all containers with status **Up**:
```
NAME                 STATUS
surveil-win-postgres   Up
surveil-win-ollama     Up
surveil-win-api       Up
surveil-win-web       Up
```

---

## Part 2: CREATE TEST ACCOUNTS

### Step 2.1: Check API is Healthy
```powershell
curl http://localhost:8080/health
```

Should return:
```json
{"status":"healthy","timestamp":"..."}
```

---

### Step 2.2: Check Database is Empty (Needs Bootstrap)
```powershell
curl http://localhost:8080/api/setup/status
```

Should return:
```json
{"requiresBootstrap":true}
```

✅ If true, continue to Step 2.3
❌ If false, go back to Step 1.1 (database still has old data)

---

### Step 2.3: Create ADMIN Account
```powershell
$adminResponse = curl -s -X POST "http://localhost:8080/api/setup/bootstrap" `
  -H "Content-Type: application/json" `
  -d '{
    "organizationName": "Test Company",
    "firstName": "Admin",
    "lastName": "User",
    "email": "admin@test.com",
    "password": "Admin@123"
  }'

Write-Host $adminResponse
```

Should return JSON with `"accessToken"`:
```json
{
  "accessToken": "eyJhbGc...",
  "refreshToken": "...",
  "user": {
    "id": "...",
    "email": "admin@test.com",
    "fullName": "Admin User",
    "role": "SuperAdmin"
  }
}
```

---

### Step 2.4: Verify Admin Login Works
```powershell
curl -X POST "http://localhost:8080/api/auth/login" `
  -H "Content-Type: application/json" `
  -d '{"email":"admin@test.com","password":"Admin@123"}'
```

Should return token (NOT "Invalid email or password")

---

### Step 2.5: Get Admin Token & Create EMPLOYEE Account
```powershell
# Get admin token
$adminLogin = curl -s -X POST "http://localhost:8080/api/auth/login" `
  -H "Content-Type: application/json" `
  -d '{"email":"admin@test.com","password":"Admin@123"}'

$adminToken = ($adminLogin | ConvertFrom-Json).accessToken

# Create employee account
curl -X POST "http://localhost:8080/api/users" `
  -H "Authorization: Bearer $adminToken" `
  -H "Content-Type: application/json" `
  -d '{
    "email": "employee@test.com",
    "firstName": "John",
    "lastName": "Doe",
    "role": "Employee"
  }'
```

Should return JSON with employee user info

---

## ✅ YOUR TEST ACCOUNTS ARE NOW READY

```
ADMIN ACCOUNT:
  Email:    admin@test.com
  Password: Admin@123
  Role:     SuperAdmin (full access)

EMPLOYEE ACCOUNT:
  Email:    employee@test.com
  Password: Employee@123
  Role:     Employee (own data only)
```

---

## Part 3: TEST THE WEB DASHBOARD

### Step 3.1: Open Web Dashboard
```
URL: http://localhost:5173
```

### Step 3.2: Login as ADMIN
Enter:
```
Email:    admin@test.com
Password: Admin@123
```

Click **Sign In**

### Step 3.3: Verify Admin Sees Everything
You should see:
- ✅ Dashboard home page
- ✅ "Employees" link in navigation
- ✅ "Activity" or "Reports" sections
- ✅ Settings/Admin options
- ✅ Employee list (currently showing 1 employee)

### Step 3.4: Test Employee Isolation
```
1. Click Logout
2. Login with Employee:
   Email:    employee@test.com
   Password: Employee@123
3. Verify you see:
   ✅ "My Activity" or "Personal Dashboard"
   ✅ Your own data only
   ❌ NO employees list
   ❌ NO admin settings
```

---

## Part 4: TEST THE DESKTOP APPLICATION

### Step 4.1: Open New PowerShell Terminal
Keep all Docker services running, open a **NEW** PowerShell window

### Step 4.2: Navigate to Project
```powershell
cd "C:\Users\skrab\Downloads\surveil-win\surveil-win"
```

### Step 4.3: Run Desktop App
```powershell
dotnet run --project apps/Dashboard.Win/Dashboard.Win.csproj
```

Wait 5-10 seconds for the WPF window to appear

### Step 4.4: Login Screen Appears
A window titled **"SurveilWin"** should appear with:
- Email field
- Password field
- "Sign In" button

### Step 4.5: Login with EMPLOYEE Account
Enter:
```
Email:    employee@test.com
Password: Employee@123
```

Click **Sign In**

### Step 4.6: Verify Login Success
After clicking Sign In, you should see the **Shift Panel** with:
- ✅ Message "Ready to Start"
- ✅ Your name displayed
- ✅ "Start Shift" button
- ✅ "Sign Out" button

If you see **red error** or **"Invalid email or password"**:
1. Check you typed credentials exactly
2. Verify API is still healthy: `curl http://localhost:8080/health`
3. Go back to Step 2.4 to verify login works at API level

---

## Part 5: TEST REAL-TIME MONITORING

### Step 5.1: Click "Start Shift"
In the Desktop App, click the **"Start Shift"** button

### Step 5.2: Verify Monitoring Starts
After clicking, you should see:
- ✅ Shift panel disappears
- ✅ **Monitoring panel** appears with:
  - Shift timer (00:00:00 and counting)
  - Status indicator (should show "Monitoring active")
  - "End Shift" button (red)
  - Activity log section at bottom

### Step 5.3: Use Your Computer
While the shift is active:
- Open **Chrome/Firefox/Edge** browser
- Open **Word** or **Notepad**
- Open **Excel** or **Calculator**
- Switch between applications

### Step 5.4: Watch Real-Time Updates
In the Monitoring Panel, you should see:
- ✅ **Frame Count** incrementing (0, 1, 2, 3...)
- ✅ **Last App** showing current application name
  - "chrome.exe" when browsing
  - "notepad.exe" when in notepad
  - etc.
- ✅ **Upload Status** showing "OK" or similar
- ✅ **Activity Log** at bottom showing captured apps

### Step 5.5: End Shift
Click the **red "End Shift"** button

### Step 5.6: Verify Shift Ends
After clicking, you should see:
- ✅ Monitoring panel disappears
- ✅ Shift panel reappears with "Ready to Start"
- ✅ Message says "Shift ended"

---

## Part 6: VERIFY DATA IN WEB DASHBOARD

### Step 6.1: Go Back to Web Dashboard
```
http://localhost:5173
```

### Step 6.2: Login as ADMIN
```
admin@test.com / Admin@123
```

### Step 6.3: View Employee Activity
Navigate to **Employees** or **Activity** section

You should see:
- ✅ The shift you just ran
- ✅ (Optional) If monitoring ran long enough, you'll see "chrome.exe", "notepad.exe", etc.
- ✅ Shift duration and status

### Step 6.4: Verify Employee CANNOT See Admin Data
```
1. Logout
2. Login as employee@test.com / Employee@123
3. Should see ONLY their own data
4. Should NOT see admin settings or other employees
```

---

## 🎉 SUCCESS CHECKLIST

After completing all steps, verify:

- ✅ Services all running (`docker-compose ps`)
- ✅ API healthy (`curl http://localhost:8080/health`)
- ✅ Web Dashboard loads (`http://localhost:5173`)
- ✅ Admin can login with `admin@test.com / Admin@123`
- ✅ Admin sees all employees and activity
- ✅ Employee can login with `employee@test.com / Employee@123`
- ✅ Employee sees ONLY own data
- ✅ Desktop app launches without errors
- ✅ Desktop app login works
- ✅ Can start shift in desktop app
- ✅ Monitoring panel shows real-time activity
- ✅ Activity appears in web dashboard after shift ends

---

## 📊 LOCAL DATABASE DETAILS

After setup:

| Component | Value |
|-----------|-------|
| Database | PostgreSQL 16 (local Docker) |
| Host | postgres (Docker) / localhost (local dev) |
| Port | 5432 |
| Database Name | surveilwin |
| Username | postgres |
| Password | postgres |
| Connection | Host=postgres;Database=surveilwin;Username=postgres;Password=postgres |
| API | http://localhost:8080 |
| Web Dashboard | http://localhost:5173 |
| Swagger Docs | http://localhost:8080/swagger |

---

## 🆘 TROUBLESHOOTING

### Issue: "Invalid email or password" at any step
**Solution:**
```powershell
# Verify API is still healthy
curl http://localhost:8080/health

# Check setup status
curl http://localhost:8080/api/setup/status

# If requiresBootstrap is false but login fails, reset:
docker-compose down
docker volume rm surveil-win_postgres_data -f
# Then start from Step 1.3
```

### Issue: Desktop app won't launch
**Solution:**
```powershell
# Make sure you're in the project directory
cd "C:\Users\skrab\Downloads\surveil-win\surveil-win"

# Try building first
dotnet build

# Then run
dotnet run --project apps/Dashboard.Win/Dashboard.Win.csproj
```

### Issue: "Cannot connect to API"
**Solution:**
```powershell
# Verify API is running
docker-compose ps | findstr api

# Check if healthy
curl http://localhost:8080/health

# If not, restart it
docker-compose restart api
# Wait 30 seconds
```

### Issue: Monitoring not showing activity
**Solution:**
1. Make sure you clicked "Start Shift"
2. Make sure monitoring panel is visible (not minimized)
3. Open different applications while monitoring
4. Wait 5-10 seconds for data to upload

---

## 🎯 NEXT STEPS AFTER TESTING

1. Explore the Web Dashboard features
2. Check Swagger documentation: http://localhost:8080/swagger
3. Test with multiple employees
4. Run shifts and monitor real productivity
5. Experiment with different application types

---

**You're now ready to test locally!** 🚀

Follow the steps above in order and let me know if you hit any issues!

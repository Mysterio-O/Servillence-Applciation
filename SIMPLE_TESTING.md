# 🚀 COMPLETE TESTING - ULTRA SIMPLE GUIDE

## ⭐ Everything is Ready! Just Follow These Steps:

---

## STEP 1: Start Docker (Super Easy)

### Option A: Double-click File (Simplest!)
1. Open Windows File Explorer
2. Navigate to: `C:\Users\skrab\Downloads\surveil-win\surveil-win`
3. **Double-click**: `START_DOCKER.bat` (a black window will appear)
4. Wait 60 seconds and close the window
5. Look for Docker icon in system tray (bottom right corner) ✓

### Option B: Using Search
1. Press `Windows Key`
2. Type: `START_DOCKER.bat`
3. Press Enter
4. Wait 60 seconds

---

## STEP 2: Run Automated Testing (Even Easier!)

1. Open PowerShell (Press Win+R, type `powershell`, press Enter)
2. Copy and paste this command:

```powershell
cd "C:\Users\skrab\Downloads\surveil-win\surveil-win"; bash test-services.sh
```

3. Press Enter
4. Wait for it to finish (about 2-3 minutes)
5. When done, you'll see URLs and instructions

---

## STEP 3: Test Web Dashboard (Admin)

When automated script finishes:

1. **Open browser** (Chrome, Edge, Firefox, etc.)
2. **Go to**: http://localhost:5173
3. You should see SurveilWin login page
4. **Try to login** with admin account:
   - Email: `admin@surveilwin.com`
   - Password: (try `password` or check in `.env` file)

### What to look for (Admin should see):
- ✅ All employees listed
- ✅ Activity feeds for all employees
- ✅ Dashboard/analytics
- ✅ Settings tab visible
- ✅ Can navigate without errors

### Take screenshots of:
- [ ] Login page
- [ ] Main dashboard
- [ ] Employee list
- [ ] Activity page
- [ ] Any errors

---

## STEP 4: Test Web Dashboard (Employee)

1. **Click logout** (profile or menu button)
2. **Login again** with employee account:
   - Email: `employee@surveilwin.com`
   - Password: (same as admin)

### What to look for (Employee should see):
- ✅ Can login successfully
- ✅ Dashboard shows ONLY own data
- ✅ Cannot see other employees
- ✅ Own shifts/activity visible
- ✅ Limited menu options

### Try to verify restrictions:
- [ ] Try clicking "Employees" → Should be disabled or hidden
- [ ] Try clicking "Admin Settings" → Should be hidden
- [ ] Try editing URL to `/admin` → Should deny or redirect
- [ ] Check that data shown is only your own

### Take screenshots of:
- [ ] Employee login screen
- [ ] Employee dashboard
- [ ] Sidebar (should be limited)
- [ ] Try accessing forbidden page

---

## STEP 5: Test Desktop Application

1. **Open NEW PowerShell window** (Win+R → `powershell`)
2. Copy and paste:

```powershell
cd "C:\Users\skrab\Downloads\surveil-win\surveil-win"
dotnet run --project apps/Dashboard.Win/Dashboard.Win.csproj
```

3. Press Enter
4. Wait for window to appear (might take 10-15 seconds)

### What you'll see:
- Black WPF window opens
- Login form should appear

### What to test:

#### Test 5a: App Launches
- [ ] Window opens
- [ ] No crash/error
- [ ] Login form visible

#### Test 5b: Login
- [ ] Enter employee email
- [ ] Enter password
- [ ] Click Login button
- [ ] App processes request

#### Test 5c: Main Screen (after login)
- [ ] Main screen appears
- [ ] Shift information shows
- [ ] Employee name displayed
- [ ] No errors

#### Test 5d: Features
- [ ] Current window/app shows
- [ ] Time updates
- [ ] Data looks reasonable

### Troubleshooting Desktop App:
If it crashes or errors:
1. Copy the ERROR message
2. Check console output
3. Note what step failed

### Take screenshots of:
- [ ] App launch
- [ ] Login screen
- [ ] Main dashboard
- [ ] Any errors

---

## STEP 6: Check API Documentation

1. **Open browser**
2. **Go to**: http://localhost:8080/swagger
3. You should see Swagger documentation with all API endpoints

### What to look for:
- ✅ Swagger page loads
- ✅ Can see "Auth" section
- ✅ Can see "Employees" section
- ✅ Can see "Activity" section

### Try clicking "Try it out":
Pick an endpoint like `/health` and click "Execute"
Should show response

---

## STEP 7: Document Your Findings

### Create a Test Report:

```
=== SURVEILWIN TEST REPORT ===

Date: [TODAY'S DATE]
Tester: [YOUR NAME]

RESULTS:
--------

☐ Docker Started Successfully (Yes/No)
☐ Services Running (Yes/No)
☐ API Health Check Passed (Yes/No)

WEB DASHBOARD - ADMIN:
☐ Can login
☐ Sees all employees
☐ Can view activity
☐ Navigation works
☐ No JavaScript errors

Issues: [DESCRIBE IF ANY]
Screenshots: [PASTE SCREENSHOTS]

WEB DASHBOARD - EMPLOYEE:
☐ Can login
☐ Sees only own data
☐ Cannot see admin features
☐ Cannot access other employees
☐ Navigation limited

Issues: [DESCRIBE IF ANY]
Screenshots: [PASTE SCREENSHOTS]

DESKTOP APPLICATION:
☐ Launches without error
☐ Login form visible
☐ Can login
☐ Main screen displays
☐ Shows shift info
☐ No crashes

Issues: [DESCRIBE IF ANY]
Errors: [ANY ERROR MESSAGES]

API DOCUMENTATION:
☐ Swagger loads
☐ All endpoints visible
☐ Can view documentation

OVERALL ASSESSMENT:
✅ Everything Works
⚠️ Some Issues (list them)
❌ Major Problems (list them)

ISSUES FOUND:
1. [ISSUE 1]
2. [ISSUE 2]
3. [ISSUE 3]
```

---

## QUICK REFERENCE

### Service URLs:
```
Web Dashboard:  http://localhost:5173
API:            http://localhost:8080
API Docs:       http://localhost:8080/swagger
Database:       localhost:5432
```

### Test Accounts (try these):
```
Admin:
  Email: admin@surveilwin.com
  Password: password (or check .env)

Employee:
  Email: employee@surveilwin.com
  Password: password (or check .env)
```

### Important Commands:

```bash
# Stop all services
docker compose down

# View logs if something breaks
docker compose logs api
docker compose logs web

# Restart a service
docker compose restart api

# Start services again
docker compose up -d
```

---

## 🎯 START HERE

### RIGHT NOW:
1. **Double-click** `START_DOCKER.bat`
2. **Wait** 60 seconds
3. **Run** the PowerShell command in STEP 2

### THEN FOLLOW STEPS 3-7

That's it! Everything else is automatic.

---

## ❓ If Something Goes Wrong

### Docker Won't Start
- Try double-clicking `START_DOCKER.bat` again
- Wait full 60 seconds
- Check system tray for Docker icon

### Services Won't Start
- Make sure Docker is fully running first
- Check firewall isn't blocking ports
- Try: `docker compose down` then `docker compose up -d`

### Can't Login
- Check username/password in `.env` file
- Try with simpler password like `test` or `password`
- Check API logs: `docker compose logs api`

### Desktop App Won't Run
- Make sure .NET 8 is installed: `dotnet --version`
- Try running from Command Prompt instead of PowerShell
- Check for error messages

### API Shows Error
- Wait another 30 seconds (might be initializing)
- Check logs: `docker compose logs api`
- Restart: `docker compose restart api`

---

## 🏁 YOU'RE ALL SET!

**Everything is ready to test. Just follow the steps above and you'll test:**
- ✅ Web Dashboard (Admin & Employee)
- ✅ Desktop Application
- ✅ API Backend
- ✅ Multi-tenant Access Control
- ✅ Data Isolation
- ✅ Authentication

**Start with STEP 1 now!** 🚀

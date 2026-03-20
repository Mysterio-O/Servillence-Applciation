# SurveilWin Complete Testing Guide - Step by Step

## ✅ COMPLETED: Desktop Application Build
- Build Status: **SUCCESS** (0 warnings, 0 errors)
- All projects compiled:
  - ✓ Utils library
  - ✓ Contracts library
  - ✓ Processing library
  - ✓ SurveilWin.Api
  - ✓ Agent.Win
  - ✓ Dashboard.Win (Desktop App)
  - ✓ Runner

---

##  STEP 1: Start Docker Desktop (Manual Action Required)

**Method A: GUI (Easiest)**
1. Press `Win + R`
2. Type: `"C:\Program Files\Docker\Docker\Docker.exe"`
3. Hit Enter
4. Wait 30-60 seconds for Docker to fully start
5. Look for Docker icon in system tray

**Method B: PowerShell (As Administrator)**
```powershell
Start-Process -FilePath "C:\Program Files\Docker\Docker\Docker Desktop Installer.exe"
```

**Verify Docker is Running:**
```bash
docker ps
```
Should show something like:
```
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
```

---

## STEP 2: Start All Services

Once Docker is running, execute in PowerShell:

```bash
cd "C:\Users\skrab\Downloads\surveil-win\surveil-win"
docker compose up -d
```

**Wait 60 seconds** for all services to start.

### Verify Services are Running:
```bash
docker compose ps
```

Expected output:
```
NAME          STATUS           PORTS
surveil-postgres    Up (healthy)     5432->5432
surveil-ollama      Up (healthy)     11434->11434
surveil-api         Up (healthy)     8080->8080
surveil-web         Up (running)     5173->80
```

### Check API Health:
```bash
curl http://localhost:8080/health
```

Should return HTTP 200 with health status.

---

## STEP 3: Test Web Dashboard (Admin)

### Access Admin Dashboard:
1. Open browser: **http://localhost:5173**
2. You should see SurveilWin login page

### Try Default Admin Login:
- **Email**: `admin@surveilwin.com`
- **Password**: (check .env or database seeds)

### Test Items:
- [ ] Login successful
- [ ] Dashboard loads without errors
- [ ] Can see employee list/data
- [ ] Can view activity feeds
- [ ] Can access settings
- [ ] Sidebar navigation works
- [ ] Can view analytics/metrics
- [ ] Real-time data appears

### Expected Admin Views:
```
Dashboard
├── Employees (List view)
├── Departments
├── Activity Monitor
├── Analytics
├── Reports
└── Settings
```

### Screenshot or Note Issues:
If login fails: Check server logs with `docker compose logs api`

---

## STEP 4: Test Web Dashboard (Employee)

### Logout Admin Account:
- Click profile menu → Logout

### Try Default Employee Login:
- **Email**: `employee@surveilwin.com`
- **Password**: (same source as admin)

### Test Items:
- [ ] Can login successfully
- [ ] Dashboard shows ONLY own data
- [ ] Cannot see other employees' data
- [ ] Cannot access admin settings
- [ ] Can view own activity
- [ ] Can see own shifts
- [ ] Can view personal metrics
- [ ] Sidebar shows limited options

### Expected Employee Views:
```
Dashboard (Limited)
├── My Activity
├── My Shifts
├── My Performance
└── Account Settings (limited)
```

### Verify Data Isolation:
- Try to access `/employees` in URL → Should redirect/deny
- Try to access admin panel → Should deny/hide
- Check network requests → Should only access own data

---

## STEP 5: Test Desktop Application (Dashboard.Win)

### Launch Desktop App:
```bash
cd "C:\Users\skrab\Downloads\surveil-win\surveil-win"
dotnet run --project apps/Dashboard.Win/Dashboard.Win.csproj
```

Or run directly:
```bash
.\apps\Dashboard.Win\bin\Debug\net8.0-windows\Dashboard.Win.exe
```

### Desktop App Test Menu:

#### 5.1: Launch & UI
- [ ] App launches without errors
- [ ] Window opens cleanly
- [ ] No exceptions in console
- [ ] UI elements are visible

#### 5.2: Login
- [ ] Login form displays
- [ ] Can enter email: `employee@surveilwin.com`
- [ ] Can enter password
- [ ] "Login" button is clickable
- [ ] Returns to main screen on success

#### 5.3: Main Features
- [ ] Shift status displays
- [ ] Employee name shows
- [ ] API connection status shown
- [ ] Current activity/window visible
- [ ] Time display updates

#### 5.4: API Integration
- [ ] Can communicate with API (check network)
- [ ] Receives data from http://localhost:8080
- [ ] Token/auth works
- [ ] Handles API errors gracefully

#### 5.5: Error Handling
- [ ] Try with invalid password → Shows error
- [ ] Try with wrong email → Shows error
- [ ] Simulate network error → App handles it
- [ ] Try with expired token → Shows login again

---

## STEP 6: API Testing (Advanced)

### Check Swagger Documentation:
```
http://localhost:8080/swagger
```

### Test Key Endpoints with curl or Postman:

**1. Health Check:**
```bash
curl http://localhost:8080/health
```

**2. Get Auth Token:**
```bash
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@surveilwin.com","password":"password"}'
```

**3. Get Employees (with token):**
```bash
curl http://localhost:8080/api/employees \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

**4. Get Activity:**
```bash
curl http://localhost:8080/api/activity \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

---

## STEP 7: Database Check (Optional)

### Connect to PostgreSQL:
```bash
psql -h localhost -U postgres -d surveilwin -W
# Password: postgres
```

### Useful Queries:
```sql
-- Check users
SELECT id, email, first_name, role FROM users;

-- Check organizations
SELECT id, name, created_at FROM organizations;

-- Check activity
SELECT id, employee_id, window_title, captured_at FROM activities LIMIT 10;

-- Check sessions
SELECT id, employee_id, started_at, ended_at FROM sessions LIMIT 10;
```

---

## STEP 8: Troubleshooting

| Issue | Solution |
|-------|----------|
| Docker won't start | Restart Docker Desktop, check WSL2 is installed |
| Port 5173 in use | `lsof -i :5173` then kill process |
| API not responding | Check: `docker compose logs api` |
| Login fails | Check credentials in `.env` file |
| Desktop app won't launch | Ensure .NET 8 SDK is installed: `dotnet --version` |
| Can't connect to API | Check firewall, ensure `http://localhost:8080` is accessible |
| Database connection error | Check PostgreSQL is running: `docker compose ps` |

---

## Final Checklist

### Web Dashboard
- [ ] Admin can login and see all data
- [ ] Employee can login and see only own data
- [ ] Data isolation working (no cross-tenant leaks)
- [ ] UI is responsive
- [ ] No JavaScript errors in console

### Desktop App
- [ ] Launches successfully
- [ ] Authenticates with API
- [ ] Shows shift information
- [ ] Displays current activity
- [ ] Syncs with API in real-time

### API
- [ ] Health endpoint responds
- [ ] JWT authentication working
- [ ] Swagger docs accessible
- [ ] Multi-tenant isolation working
- [ ] Database queries successful

### Services
- [ ] PostgreSQL: Active
- [ ] Ollama: Active
- [ ] API: Active & Healthy
- [ ] Web: Active & Running

---

## Documenting Issues

If you find any issues, note:
1. **What you were doing** (specific steps)
2. **What happened** (actual vs expected)
3. **Error message** (if any)
4. **Screenshots** (helpful for UI issues)
5. **Environment info** (OS, Docker version, .NET version)

Example:
```
ISSUE: Admin dashboard shows 500 error on /employees page
STEPS: 1. Logged in as admin, 2. Clicked Employees link
ERROR: "TypeError: Cannot read property 'map' of undefined"
CONSOLE: Check browser DevTools
```

---

## Quick Commands Reference

```bash
# Docker Compose
docker compose up -d              # Start all services
docker compose down               # Stop all services
docker compose ps                 # Check service status
docker compose logs api           # See API logs
docker compose logs web           # See web logs
docker compose restart api        # Restart API

# .NET Apps
dotnet build                      # Build solution
dotnet run --project apps/Dashboard.Win/Dashboard.Win.csproj  # Run desktop app

# Curl/API Testing
curl http://localhost:8080/health
curl http://localhost:5173        # Check web
```

---

**Ready to proceed! Follow Step 1 first, then I'll guide you through each testing phase.** 🚀

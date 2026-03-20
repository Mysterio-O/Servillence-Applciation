# SurveilWin Complete Testing Guide

## System Architecture

```
┌─────────────────────────────────────────────────────┐
│  Web Dashboard (React)                              │
│  - Admin: http://localhost:5173                     │
│  - Employee: http://localhost:5173 (different role) │
└────────────────┬────────────────────────────────────┘
                 │
    ┌────────────┴─────────────┐
    │                          │
┌───▼──────────────┐  ┌────────▼──────────────┐
│  Desktop App     │  │  API                  │
│  Dashboard.Win   │  │  http://localhost:8080│
│  (WPF)           │  │  PostgreSQL           │
└──────────────────┘  └────────────────────────┘
         │                      │
         └──────────┬───────────┘
                    │
            ┌───────▼────────┐
            │  Ollama AI     │
            │  (11434)       │
            └────────────────┘
```

## Test Scenarios

### 1. WEB DASHBOARD - ADMIN SIDE (Full Access)
**User**: Admin account
**Expected Access**:
- [ ] View all employees in organization
- [ ] View all departments
- [ ] View activity feeds for all employees
- [ ] View analytics and productivity metrics
- [ ] Manage teams and assignments
- [ ] Access system settings

### 2. WEB DASHBOARD - EMPLOYEE SIDE (Limited Access)
**User**: Employee account
**Expected Access**:
- [ ] View own activity history only
- [ ] View own shifts
- [ ] View personal productivity metrics
- [ ] Cannot view other employees' data
- [ ] Cannot access admin settings

### 3. DESKTOP APPLICATION (Dashboard.Win)
**Purpose**: Employee-facing desktop monitoring
**Test Cases**:
- [ ] Launch Dashboard.Win successfully
- [ ] Login with employee credentials
- [ ] Shift management interface works
- [ ] Real-time sync with API
- [ ] Activity capture and logging

### 4. API INTEGRATION
**Base URL**: http://localhost:8080
**Test Cases**:
- [ ] Health check endpoint responds
- [ ] JWT authentication working
- [ ] Multi-tenant isolation (orgs don't see each other's data)
- [ ] Swagger documentation accessible

## Default Test Accounts

After initial setup, you should have:

1. **Admin Account**
   - Email: admin@surveilwin.com
   - Role: SuperAdmin/OrgAdmin
   - Used for: Testing admin dashboard features

2. **Employee Account**
   - Email: employee@surveilwin.com
   - Role: Employee
   - Used for: Testing employee dashboard + desktop app

3. **Manager Account** (Optional)
   - Email: manager@surveilwin.com
   - Role: Manager
   - Used for: Testing team view functionality

## Services & Endpoints

| Service       | Type     | URL                      | Status |
|---------------|----------|--------------------------|--------|
| Web Dashboard | React    | http://localhost:5173    | Port 5173 |
| API           | .NET     | http://localhost:8080    | Port 8080 |
| API Docs      | Swagger  | http://localhost:8080/swagger | Browser |
| Database      | Postgres | localhost:5432           | Internal |
| Ollama AI     | ML       | http://localhost:11434   | Port 11434 |

## Docker Compose Services

```yaml
Services Running:
- postgres:16 (Database)
- ollama (AI Engine)
- api (ASP.NET Core)
- web (React Dashboard)
```

## Testing Steps

1. **Startup (Automated)**
   ```
   Docker Compose up -d
   Wait 30-60 seconds for services to be healthy
   ```

2. **Verify Services**
   ```
   docker compose ps
   curl http://localhost:8080/health
   ```

3. **Access Dashboard**
   - Open: http://localhost:5173
   - Login as Admin or Employee

4. **Build Desktop App**
   ```
   cd C:\Users\skrab\Downloads\surveil-win\surveil-win
   dotnet build SurveilWin.sln
   ```

5. **Run Desktop App**
   ```
   dotnet run --project apps/Dashboard.Win/Dashboard.Win.csproj
   ```

## Key Features to Verify

### Admin Dashboard
- [ ] Multi-tenant data isolation
- [ ] User management
- [ ] Team/department structure
- [ ] Real-time activity monitoring
- [ ] Productivity scoring
- [ ] AI summaries (if Ollama ready)

### Employee Dashboard
- [ ] Personal activity history
- [ ] Shift management
- [ ] Time tracking
- [ ] Self-report (if enabled)

### Desktop App
- [ ] Runs without admin elevation
- [ ] Connects to API
- [ ] Displays shift status
- [ ] Shows login status
- [ ] Error handling for offline scenarios

## Common Issues & Solutions

| Issue | Solution |
|-------|----------|
| Docker not starting | Ensure Docker Desktop is running |
| Port 5173 already in use | `lsof -i :5173` then kill process |
| Database connection error | Check .env file, verify DB_CONNECTION_STRING |
| API not responding | Check logs: `docker compose logs api` |
| Auth login fails | Verify JWT_SECRET is set in .env |

---

**Next Steps**: Monitor Docker installation completion, then execute `docker compose up -d`

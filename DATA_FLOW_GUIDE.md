# SurveilWin - Component & Data Flow Guide

## 🏗️ **Component Execution Flow**

```
┌─────────────────────────────────────────────────────────────────┐
│                    EMPLOYEE WORKSTATION                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────────┐          ┌──────────────────────┐        │
│  │  Dashboard.Win   │          │    Agent.Win         │        │
│  │  (WPF Front-End) │──────────│ (WinForms Monitor)  │        │
│  │                  │          │                      │        │
│  │ • Login UI       │ Spawns   │ • Screenshot        │        │
│  │ • Shift Manager  │ ─────────│ • Active Window     │        │
│  │ • Activity View  │ (on      │ • OCR Text Extract  │        │
│  │ • Real-time      │  shift   │ • Embeddings (ONNX) │        │
│  │   monitoring     │  start)  │ • Local Buffering   │        │
│  └────────┬─────────┘          └──────────┬───────────┘        │
│           │                                │                    │
│           └────────────────────┬───────────┘                    │
│                                │                                │
│                  JWT Token     │                                │
│                  Activity Data │                                │
│                  Batch Upload  │                                │
│                                ▼                                │
└─────────────────────────────────────────────────────────────────┘
                                 │
                    ┌────────────▼──────────────┐
                    │   Network (Localhost)    │
                    └────────────┬──────────────┘
                                 │
        ┌────────────────────────┼────────────────────────┐
        │                        │                        │
        ▼                        ▼                        ▼
┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐
│  SurveilWin.Api  │  │ SurveilWin.Web   │  │  PostgreSQL      │
│  (REST Backend)  │  │  (React UI)      │  │  (Data Store)    │
│                  │  │                  │  │                  │
│ • Auth           │  │ • Dashboard      │  │ • Organizations  │
│ • Activity APIs  │  │ • Employee List  │  │ • Users          │
│ • Shift Control  │  │ • Analytics      │  │ • Activity       │
│ • User Mgmt      │  │ • Reports        │  │ • Shifts         │
│ • Multi-tenant   │  │ • Settings       │  │ • Screenshots    │
│                  │  │                  │  │                  │
└───────┬──────────┘  └────────┬─────────┘  └────────┬─────────┘
        │                      │                     │
        └──────────────────────┼─────────────────────┘
                               │
                    ┌──────────▼──────────┐
                    │  Ollama AI Engine   │
                    │  (Summary Gen)      │
                    └─────────────────────┘
```

---

## 🔄 **Typical Workflow**

### **1️⃣ Employee Start of Day**

```
STEP 1: Login to Desktop (Dashboard.Win)
├─ Email: employee@surveilwin.com
├─ Password: password
└─ Desktop app authenticated via JWT

↓ ↓ ↓

STEP 2: Shift Panel Displays
├─ Name: "John Doe"
├─ Message: "Ready to Start"
└─ Buttons: "Start Shift" / "Sign Out"

↓ ↓ ↓

STEP 3: Click "Start Shift"
├─ API creates shift record
├─ Dashboard.Win shifts to Monitoring Panel
├─ Agent.Win spawned in background
└─ Monitoring begins

↓ ↓ ↓

STEP 4: Monitoring Active
├─ Agent.Win captures every 1 second (1 FPS)
├─ Screenshots sent to disk (data/screenshots/)
├─ OCR extracts visible text
├─ ONNX embeddings generated
├─ Data buffered locally in data/sessions/
├─ Batches uploaded to API every X seconds
└─ Dashboard shows real-time:
   ├─ Frame count
   ├─ Current app
   ├─ Upload status
   └─ Activity log
```

### **2️⃣ Manager/Admin Viewing Dashboard**

```
STEP 1: Login to Web Dashboard (http://localhost:5173)
├─ Email: admin@surveilwin.com
├─ Password: password
└─ API returns JWT token

↓ ↓ ↓

STEP 2: Dashboard Home Page
├─ Shows all active employees
├─ Displays shift status
├─ Shows productivity scores
└─ Real-time activity feed

↓ ↓ ↓

STEP 3: Click on Employee
├─ View detailed activity
├─ See screenshots (if available)
├─ Check app/category breakdown
└─ View shift duration

↓ ↓ ↓

STEP 4: Check Reports
├─ Daily productivity report
├─ Team performance metrics
├─ Category usage breakdown
└─ Time tracking analysis
```

### **3️⃣ End of Shift**

```
STEP 1: Employee Clicks "End Shift"
├─ Dashboard.Win closes monitoring panel
├─ Agent.Win process terminates
├─ Remaining buffered data synced
├─ Session finalized
└─ Back to shift panel

↓ ↓ ↓

STEP 2: Data Processing
├─ API finalizes shift record
├─ Database updates shift status
├─ AI generates daily summary (if Ollama available)
└─ Screenshots retained per config

↓ ↓ ↓

STEP 3: Available for Review
├─ Manager can view completed shift
├─ Admin can view all shifts
├─ Employee sees own shift summary
└─ Data retained based on config
   ├─ Thumbnails: 7 days
   ├─ Summaries: 90 days
   └─ Full data: configurable
```

---

## 📊 **Data Models**

### **User Entity**
```
User
├─ Id: guid
├─ Email: string
├─ PasswordHash: string
├─ Name: string
├─ OrganizationId: guid ◄── Multi-tenant isolator
├─ Role: enum (SuperAdmin, OrgAdmin, Manager, Employee)
├─ Department: string
├─ IsActive: bool
├─ CreatedAt: datetime
└─ LastLogin: datetime
```

### **Shift Entity**
```
Shift
├─ Id: guid
├─ UserId: guid
├─ OrganizationId: guid
├─ StartTime: datetime
├─ EndTime: datetime?
├─ TotalDuration: timespan
├─ Status: enum (Active, Completed, AutoClosed)
├─ ActivityCount: int
└─ Productivity: decimal (0-100)
```

### **Activity Entity**
```
Activity
├─ Id: guid
├─ ShiftId: guid
├─ UserId: guid
├─ OrganizationId: guid
├─ Timestamp: datetime
├─ ActiveWindow: string
├─ Category: enum (Development, Communication, Design, etc.)
├─ Productivity: decimal (0-100)
├─ ScreenshotPath: string?
├─ OcrText: string?
├─ Embedding: float[]
└─ Metadata: json
```

### **Screenshot Entity**
```
Screenshot
├─ Id: guid
├─ ActivityId: guid
├─ ShiftId: guid
├─ UserId: guid
├─ ThumbnailPath: string
├─ Timestamp: datetime
├─ Width: int
├─ Height: int
├─ FileSize: long
└─ DeletedAt: datetime? (for retention)
```

---

## 🔐 **Multi-Tenant Isolation Architecture**

```
┌──────────────────────────────────────────────────────┐
│            SurveilWin.Api Request Pipeline           │
├──────────────────────────────────────────────────────┤
│                                                      │
│  1. Authentication Middleware                       │
│     ├─ Extract JWT token                            │
│     ├─ Validate signature & expiry                  │
│     └─ Extract UserId & OrganizationId              │
│                                                      │
│  2. Authorization Middleware                        │
│     ├─ Check role permissions                       │
│     ├─ Add OrganizationId to context                │
│     └─ Reject if insufficient access                │
│                                                      │
│  3. Data Access Layer                               │
│     ├─ AUTOMATICALLY FILTER by OrganizationId       │◄── CRITICAL
│     ├─ Apply role-based filters                     │
│     └─ Return only authorized data                  │
│                                                      │
│  4. Response Serialization                          │
│     └─ Return filtered results                      │
│                                                      │
└──────────────────────────────────────────────────────┘
```

### **Isolation Rules**

| Role | Can See | Cannot See |
|------|---------|-----------|
| **SuperAdmin** | Everything | Nothing |
| **OrgAdmin** | Org employees, shifts, activity | Other orgs |
| **Manager** | Team employees only | Other teams, other orgs |
| **Employee** | Own activity only | Others' data, org data |

---

## 🔌 **API Endpoints Reference**

### **Authentication**
```
POST /api/auth/login
  Body: { email, password }
  Returns: { token, refreshToken, expiresIn }

POST /api/auth/refresh
  Body: { refreshToken }
  Returns: { token, refreshToken, expiresIn }

POST /api/auth/setup
  Body: { email, password, organizationName }
  Returns: { token, organization }
```

### **User Management**
```
GET /api/users
  Returns: User[] (filtered by org)

GET /api/users/{id}
  Returns: User

POST /api/users
  Body: { email, name, role, departmentId }
  Returns: User

PUT /api/users/{id}
  Body: { name, phone, department }
  Returns: User
```

### **Shift Management**
```
GET /api/shifts
  Returns: Shift[] (filtered by org/user)

POST /api/shifts
  Body: { userId }
  Returns: Shift (started)

GET /api/shifts/{id}
  Returns: Shift with activities

PATCH /api/shifts/{id}
  Body: { status }
  Returns: Shift (updated)
```

### **Activity Tracking**
```
GET /api/activity
  Query: ?startDate=&endDate=&userId=&category=
  Returns: Activity[] (paginated)

POST /api/activity
  Body: { shiftId, activeWindow, category, screenshot }
  Returns: Activity (created)

GET /api/activity/{id}
  Returns: Activity with screenshot info
```

### **Reports**
```
GET /api/reports/productivity
  Query: ?userId=&startDate=&endDate=
  Returns: { productivity, breakdown }

GET /api/reports/activity-summary
  Query: ?userId=&date=
  Returns: { summary, topApps, timeSpent }

GET /api/reports/team
  Query: ?managerId=&date=
  Returns: TeamReport[]
```

---

## 🖼️ **Screenshots & Storage**

```
┌─────────────────────────────────────────┐
│         Screenshot Lifecycle            │
├─────────────────────────────────────────┤
│                                         │
│ CAPTURE (Agent.Win)                    │
│ ├─ Every 1 second                      │
│ ├─ Default resolution                  │
│ └─ Saved locally in data/sessions/     │
│                                         │
│         ▼                               │
│                                         │
│ PROCESS (Agent.Win)                    │
│ ├─ Generate thumbnail (75% quality)    │
│ ├─ Extract OCR text                    │
│ ├─ Generate ONNX embedding             │
│ └─ Local buffer                        │
│                                         │
│         ▼                               │
│                                         │
│ UPLOAD (Batch)                         │
│ ├─ Upload to API periodically          │
│ ├─ Store in database                   │
│ └─ Move to server storage              │
│                                         │
│         ▼                               │
│                                         │
│ RETENTION (Configurable)               │
│ ├─ Thumbnails: 7 days                  │
│ ├─ Summaries: 90 days                  │
│ └─ Full data: Per policy               │
│                                         │
│         ▼                               │
│                                         │
│ CLEANUP                                │
│ └─ Automated deletion                  │
│                                         │
└─────────────────────────────────────────┘
```

---

## 🎯 **Testing Scenarios**

### **Scenario 1: Single Employee Monitoring**
1. Start Desktop App
2. Login as employee
3. Start shift
4. Use various applications
5. Watch monitoring panel update
6. View in Web Dashboard (as admin)

### **Scenario 2: Multi-Tenant Isolation**
1. Create Organization A & B
2. Create employees in each org
3. Login to admin account from Org A
4. Verify only seeing Org A employees
5. Switch to Org B admin account
6. Verify only seeing Org B employees

### **Scenario 3: Role-Based Access**
1. Login as SuperAdmin
2. Verify can access all data
3. Logout, login as OrgAdmin
4. Verify can only see org employees
5. Logout, login as Manager
6. Verify can only see assigned team
7. Logout, login as Employee
8. Verify can only see own data

### **Scenario 4: Offline Buffering**
1. Start shift
2. Disconnect network
3. Use applications (activity recorded locally)
4. Reconnect network
5. Verify all buffered data syncs
6. Check in Web Dashboard

### **Scenario 5: Performance Under Load**
1. Start multiple employees' shifts
2. Let run for 10+ minutes
3. Monitor CPU/Memory usage
4. Check database performance
5. Verify no data loss
6. Review batch upload efficiency

---

## 📈 **Metrics Schema**

### **Productivity Score Formula**
```
Score = (FocusTime / TotalTime) * 100

Where:
- FocusTime = Time on productive apps
- TotalTime = Total monitoring time

Categories:
├─ Development: 100 points
├─ Communication: 80 points
├─ Design: 90 points
├─ Social Media: 20 points
├─ Entertainment: 10 points
└─ Other: 50 points
```

### **Activity Categories**
- Development
- Communication
- Design & Creative
- Sales & Marketing
- Administrative
- Meetings
- Social Media
- Entertainment
- Other

---

## 🔧 **Debugging Tips**

### **Check Agent Status**
```bash
# View running processes
tasklist | find "Agent.Win"
tasklist | find "Dashboard.Win"

# Check screenshot directory
ls -la data/sessions/
ls -la data/screenshots/

# View logs
cat data/sessions/[session-id].log
```

### **View Activity Data**
```bash
# Check what was captured
GET http://localhost:8080/api/activity?limit=10

# View specific activity
GET http://localhost:8080/api/activity/{id}

# View shifts
GET http://localhost:8080/api/shifts?userId=[userId]
```

### **Database Queries (PostgreSQL)**
```sql
-- Check users
SELECT * FROM users WHERE organization_id = '[org-id]';

-- Check shifts
SELECT * FROM shifts WHERE user_id = '[user-id]' ORDER BY start_time DESC;

-- Check activity
SELECT COUNT(*) FROM activities WHERE shift_id = '[shift-id]';

-- Check screenshots
SELECT COUNT(*) FROM screenshots WHERE shift_id = '[shift-id]';
```

---

**Generated**: 2026-03-20

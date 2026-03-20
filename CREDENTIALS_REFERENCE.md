# 🔐 SurveilWin Test Credentials - Complete Reference

## Current Status

Your database was previously bootstrapped with an account we need to identify or reset.

---

## ✅ CREDENTIALS AFTER FRESH SETUP

When you run the setup scripts, these credentials will work for **BOTH** Web Dashboard and Desktop App:

### **Admin Account**
```
📧 Email:    admin@test.com
🔑 Password: Admin@123
👤 Role:     SuperAdmin
```

**Permissions:**
- ✅ View all employees
- ✅ View all activity & monitoring
- ✅ View analytics and reports
- ✅ Manage organization
- ✅ Manage users and roles
- ✅ View shift history for all users

### **Employee Account**
```
📧 Email:    employee@test.com
🔑 Password: Employee@123
👤 Role:     Employee
```

**Permissions:**
- ✅ View own activity only
- ✅ Start/end own shifts
- ✅ View own activity monitoring
- ❌ Cannot see other employees' data
- ❌ Cannot access admin features
- ❌ Cannot view organization settings

---

## 🚀 HOW TO GET WORKING CREDENTIALS

### **Option 1: Fresh Setup (RECOMMENDED)**

```bash
cd "C:\Users\skrab\Downloads\surveil-win\surveil-win"

# Step 1: Reset database
docker-compose down
docker volume rm surveil-win_postgres_data

# Step 2: Restart services
bash run-services.sh
# Wait 60 seconds

# Step 3: Create accounts
bash CREATE_TEST_ACCOUNTS.sh
```

This will create:
- ✅ `admin@test.com` / `Admin@123`
- ✅ `employee@test.com` / `Employee@123`

---

### **Option 2: Quick Bootstrap (if database empty)**

```bash
# Check setup status
curl http://localhost:8080/api/setup/status

# If requiresBootstrap is true, run:
curl -X POST http://localhost:8080/api/setup/bootstrap \
  -H "Content-Type: application/json" \
  -d '{
    "organizationName": "Test Organization",
    "firstName": "Admin",
    "lastName": "User",
    "email": "admin@test.com",
    "password": "Admin@123"
  }'
```

---

## 📋 USE THESE CREDENTIALS IN BOTH APPLICATIONS

### **Web Dashboard**
- URL: http://localhost:5173
- Login with ADMIN or EMPLOYEE account above
- Admin sees all data
- Employee sees only own data

### **Desktop Application (Dashboard.Win)**
- Command: `dotnet run --project apps/Dashboard.Win/Dashboard.Win.csproj`
- Use EMPLOYEE account (or admin)
- Starts monitoring when shift begins
- Real-time activity capture and display

---

## 🔑 Password Format Explained

Passwords MUST contain:
- ✅ 8+ characters
- ✅ At least 1 UPPERCASE letter (A, B, C...)
- ✅ At least 1 lowercase letter (a, b, c...)
- ✅ At least 1 digit (0, 1, 2...)
- ✅ At least 1 special character (@, #, $, %, !)

**Examples that work:**
- `Admin@123` ✅
- `Test@Pass456` ✅
- `Employee#2024` ✅
- `Demo!Pass123` ✅

**Examples that DON'T work:**
- `password` ❌ (no uppercase, digit, special char)
- `Admin123` ❌ (no special character)
- `pass@word` ❌ (only 9 chars, needs to check all requirements)

---

## 📊 Account Roles Explained

### **SuperAdmin (admin@test.com)**
- Highest level of access
- Can see all organizations (if multi-tenant)
- Can see all employees in org
- Can see all activity and monitoring data
- Can manage all settings
- Recommended for: Testing management features

### **OrgAdmin (optional)**
- Can manage own organization
- Can see all employees in org
- Can manage users in org
- Cannot access super admin features

### **Manager (optional)**
- Can see assigned team members only
- Can view team activity
- Cannot access admin features

### **Employee (employee@test.com)**
- Can only see own data
- Can start/end own shifts
- Can view own activity
- Recommended for: Testing desktop app & monitoring

---

## 🧪 Testing Workflow

### **As Admin:**
1. Open http://localhost:5173
2. Login with `admin@test.com` / `Admin@123`
3. View dashboard (see all employees)
4. View activity feed
5. Check reports and analytics

### **As Employee:**
1. **Web**: http://localhost:5173 (employee view)
   - Login with `employee@test.com` / `Employee@123`
   - See only own activity

2. **Desktop**: Run `dotnet run --project apps/Dashboard.Win/Dashboard.Win.csproj`
   - Login with `employee@test.com` / `Employee@123`
   - Click "Start Shift"
   - Monitor real-time activity
   - Click "End Shift"

3. **Verify in Web Dashboard** (as admin):
   - Login as `admin@test.com` / `Admin@123`
   - See employee's shift and activity

---

## ✨ If You Forget Credentials

After running `CREATE_TEST_ACCOUNTS.sh`:
- **Admin**: `admin@test.com` / `Admin@123`
- **Employee**: `employee@test.com` / `Employee@123`

If you need to reset:
```bash
docker-compose down
docker volume rm surveil-win_postgres_data
```

Then repeat the setup process above.

---

## 🆘 Troubleshooting

### Login fails with "Invalid email or password"
- ✅ Make sure you typed the email exactly: `admin@test.com`
- ✅ Make sure password is exactly: `Admin@123`
- ✅ Check database was bootstrapped: `curl http://localhost:8080/api/setup/status`
- ✅ If not bootstrapped, run bootstrap endpoint

### Can't start shift in Desktop App
- ✅ Make sure API is running: `curl http://localhost:8080/health`
- ✅ Make sure you logged in successfully first
- ✅ Check `.env` has correct API URL: `http://localhost:8080`

### Employee account doesn't exist
- Run: `bash CREATE_TEST_ACCOUNTS.sh`
- Or create via API as shown below

### Create Employee via API
```bash
# 1. Get admin token
ADMIN_TOKEN=$(curl -s -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@test.com","password":"Admin@123"}' \
  | grep -o '"accessToken":"[^"]*"' | cut -d'"' -f4)

# 2. Create employee user
curl -X POST http://localhost:8080/api/users \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "employee@test.com",
    "firstName": "John",
    "lastName": "Doe",
    "role": "Employee"
  }'
```

---

## 📝 Quick Reference Card

Print this and keep it handy:

```
ADMIN LOGIN:
  Email: admin@test.com
  Pass:  Admin@123

EMPLOYEE LOGIN:
  Email: employee@test.com
  Pass:  Employee@123

WEB DASHBOARD:
  http://localhost:5173

DESKTOP APP:
  dotnet run --project apps/Dashboard.Win/Dashboard.Win.csproj

API HEALTH:
  curl http://localhost:8080/health

SWAGGER DOCS:
  http://localhost:8080/swagger
```

---

**Generated**: 2026-03-20
**Status**: Ready for testing ✅

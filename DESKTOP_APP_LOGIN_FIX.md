# SurveilWin Desktop App - Login Troubleshooting Guide

## 🔴 Problem
The Desktop App (Dashboard.Win) cannot login with credentials `admin@surveilwin.com / password`

## ✅ Solutions

### **Solution 1: Reset Database & Create Fresh Test Accounts** (RECOMMENDED)

This is the cleanest approach - reset the database and create test accounts with known credentials.

#### Step 1: Stop Services
```bash
# Open PowerShell and run:
cd "C:\Users\skrab\Downloads\surveil-win\surveil-win"
docker-compose down
docker volume rm surveil-win_postgres_data  # Delete database
```

#### Step 2: Start Fresh Services
```bash
bash run-services.sh
```
This will take 30-60 seconds as it recreates and migrates the database.

#### Step 3: Bootstrap with Test Accounts
```bash
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

**Response should be:**
```json
{
  "accessToken": "[JWT token]",
  "refreshToken": "[refresh token]",
  "user": {
    "id": "...",
    "email": "admin@test.com",
    "fullName": "Admin User",
    "role": "SuperAdmin",
    "organizationId": "...",
    "orgName": "Test Organization"
  }
}
```

#### Step 4: Test Login in Desktop App
Enter these credentials in Dashboard.Win:
- **Email**: `admin@test.com`
- **Password**: `Admin@123`

---

### **Solution 2: Use Web Dashboard First**

If you just want to test the Web Dashboard without resetting:

1. Open http://localhost:5173
2. Login with credentials shown in web (if available)
3. Check what user accounts exist

---

### **Solution 3: Automated Reset Scripts** (COMING SOON)

I've created helper scripts - use them to automate the process:

```bash
# Reset database and recreate
bash RESET_DB.sh

# Then bootstrap with test accounts
bash SETUP_API.sh
```

---

## 🔍 Why This Happened

The SurveilWin.Api uses **BCrypt password hashing** with strong password requirements:
- ✅ Minimum 8 characters
- ✅ Uppercase letter required
- ✅ Lowercase letter required
- ✅ Digit required
- ✅ Special character required

The simple password `"password"` doesn't meet these requirements, so the bootstrap must have used a different account or the database was pre-seeded with different credentials.

---

## 🎯 Complete Setup Instructions

### For Fresh Testing

```bash
# 1. Terminal 1: Start services
cd "C:\Users\skrab\Downloads\surveil-win\surveil-win"
bash run-services.sh

# 2. Terminal 2: Bootstrap API (wait 30 seconds after run-services.sh)
curl -X POST http://localhost:8080/api/setup/bootstrap \
  -H "Content-Type: application/json" \
  -d '{
    "organizationName": "Test Organization",
    "firstName": "Admin",
    "lastName": "User",
    "email": "admin@test.com",
    "password": "Admin@123"
  }'

# 3. Terminal 3: Run Desktop App (wait 10 seconds)
dotnet run --project apps/Dashboard.Win/Dashboard.Win.csproj

# 4. Test with credentials:
#    Email: admin@test.com
#    Password: Admin@123
```

---

## 📋 Password Requirements Explained

Any password used for SurveilWin must pass this validation:

```csharp
private static bool IsValidPassword(string pw) =>
    pw.Length >= 8 &&
    pw.Any(char.IsUpper) &&          // At least 1 uppercase
    pw.Any(char.IsLower) &&          // At least 1 lowercase
    pw.Any(char.IsDigit) &&          // At least 1 digit
    pw.Any(c => !char.IsLetterOrDigit(c));  // At least 1 special char
```

**Valid Examples:**
- `Admin@123`
- `Test@Password456`
- `Employee#2024`
- `Demo!Pass123`

**Invalid Examples:**
- ❌ `password` - no uppercase, digit, special char
- ❌ `Admin123` - no special character
- ❌ `Admin@` - no digit

---

## 🔑 After Bootstrap - Creating Additional Users

Once you have your admin account, you can create employee accounts via the API:

```bash
# Get admin token first
ADMIN_TOKEN=$(curl -s -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@test.com","password":"Admin@123"}' \
  | grep -o '"accessToken":"[^"]*"' | cut -d'"' -f4)

# Create new user (requires Admin@123 pattern)
curl -X POST http://localhost:8080/api/users \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "employee@test.com",
    "firstName": "John",
    "lastName": "Doe",
    "departmentId": null,
    "role": "Employee"
  }'
```

---

## 🆘 Still Having Issues?

### Check API Health
```bash
curl http://localhost:8080/health
# Should return: {"status":"Healthy","timestamp":"..."}
```

### View Swagger Documentation
Open http://localhost:8080/swagger to explore all endpoints

### Check Database Connection
The .env file contains Neon cloud database URL (PostgreSQL). Verify it:
```bash
cat .env | grep DB_CONNECTION
```

### View Docker Logs
```bash
docker-compose logs api     # API logs
docker-compose logs postgres  # Database logs
docker-compose logs web       # Web dashboard logs
```

### Reset Everything
```bash
# Complete reset
docker-compose down
docker volume rm surveil-win_postgres_data
docker-compose up -d
# Wait 60 seconds, then bootstrap again
```

---

## 📊 Test Credentials Reference

After successful bootstrap, use these for testing:

**Admin Account:**
```
Email: admin@test.com
Password: Admin@123
Role: SuperAdmin (all access)
```

**To Create Employee:**
```
Email: employee@test.com
Password: Employee@123
Role: Employee (own data only)
```

---

**Next Steps:**
1. Follow Solution 1 steps above
2. Your desktop app should login successfully
3. Start a shift and monitor activity
4. Check Web Dashboard to see activity as admin

---

Generated: 2026-03-20

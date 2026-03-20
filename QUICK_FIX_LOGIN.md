# 🔧 Desktop App Login Fix - Complete Steps

## ✅ What I've Done:
1. ✅ Identified the issue: Database was using Neon cloud (with unknown credentials)
2. ✅ Updated `.env` to use local PostgreSQL from Docker
3. ✅ Created test account credentials

---

## 🚀 TO FIX YOUR LOGIN ISSUE - FOLLOW THESE STEPS:

### **Step 1: Restart Services with Local Database**

Open **PowerShell** and run:

```powershell
cd "C:\Users\skrab\Downloads\surveil-win\surveil-win"
docker-compose down
```

Then wait 5 seconds, then run:

```powershell
bash run-services.sh
```

Wait 60 seconds for services to start.

---

### **Step 2: Bootstrap API with Test Account**

Open a **new PowerShell** window (keep the services running) and run:

```powershell
curl -X POST http://localhost:8080/api/setup/bootstrap `
  -H "Content-Type: application/json" `
  -d '{
    "organizationName": "Test Company",
    "firstName": "Admin",
    "lastName": "User",
    "email": "admin@test.com",
    "password": "Admin@123"
  }'
```

Should see response like:
```json
{
  "accessToken": "eyJhbGc...",
  "refreshToken": "...",
  "user": {
    "id": "...",
    "email": "admin@test.com",
    "fullName": "Admin User",
    "role": "SuperAdmin",
    ...
  }
}
```

---

### **Step 3: Test in Desktop App**

Open **another PowerShell** window and run:

```powershell
cd "C:\Users\skrab\Downloads\surveil-win\surveil-win"
dotnet run --project apps/Dashboard.Win/Dashboard.Win.csproj
```

When the app launches, enter:
- **Email**: `admin@test.com`
- **Password**: `Admin@123`

Click **"Sign In"**

✅ You should see the **Shift Panel** with your account info!

---

## 📋 Summary of Changes

| Item | Before | After |
|------|--------|-------|
| Database | Neon Cloud URL | Local PostgreSQL (Docker) |
| Config File | `.env` (old Neon URL) | `.env` (localhost) |
| Login Credentials | Unknown | `admin@test.com` / `Admin@123` |
| Password | Simple "password" | Strong `Admin@123` (BCrypt) |

---

## 🔐 Why the Strong Password?

SurveilWin requires:
- ✅ 8+ characters
- ✅ Uppercase letter (A)
- ✅ Lowercase letter (a)
- ✅ Digit (1,2,3...)
- ✅ Special character (@,#,$,%)

Example: `Admin@123` ✅

---

## 🆘 If you still have issues:

### Test 1: Check API Health
```powershell
curl http://localhost:8080/health
```
Should return: `{"status":"Healthy","timestamp":"..."}`

### Test 2: Manual Login Test
```powershell
curl -X POST http://localhost:8080/api/auth/login `
  -H "Content-Type: application/json" `
  -d '{"email":"admin@test.com","password":"Admin@123"}'
```
Should return access token

### Test 3: Check Services Running
```powershell
# See if containers are up
docker-compose ps
```

Should show:
- postgres: UP
- ollama: UP
- api: UP
- web: UP

---

## 📁 Files Modified

- ✅ `.env` - Changed DB_CONNECTION_STRING to local PostgreSQL
- ✅ `DESKTOP_APP_LOGIN_FIX.md` - Troubleshooting guide
- ✅ `FIX_LOGIN.sh` - Automated fix script
- ✅ `SETUP_API.sh` - Manual bootstrap script
- ✅ `RESET_DB.sh` - Database reset script

---

## ✨ Next Steps After Login Works:

1. **Start a Shift**
   - Click "Start Shift" button
   - Watch monitoring panel begin capturing activity

2. **Use different applications**
   - Open Chrome, Word, Excel, etc.
   - See them appear in the monitoring panel

3. **View in Web Dashboard**
   - Open http://localhost:5173
   - Login with same credentials
   - See your activity as an admin would

4. **Create Employee Account** (Optional)
   ```powershell
   # Call API to create employee user
   ```

---

## 📞 Still Need Help?

Make sure:
1. ✅ Docker services are running (`docker-compose ps` shows all UP)
2. ✅ API is healthy (`curl http://localhost:8080/health`)
3. ✅ Used exactly: `admin@test.com` / `Admin@123`
4. ✅ Waited 60+ seconds after `bash run-services.sh`
5. ✅ Waited 30 seconds after bootstrap before launching desktop app

---

**Generated**: 2026-03-20
**Status**: Ready for testing ✅

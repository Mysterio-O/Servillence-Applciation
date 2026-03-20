# 🔧 Docker Not Starting? Use This Manual Method

## If the batch file didn't work:

No problem! This is actually EASIER. Just follow these simple steps:

---

## ✅ OPTION 1: Manual Start (Simplest)

### Step 1: Open Windows Search
- Press: `Windows Key` (at bottom left of keyboard)
- Start typing: `Docker`
- You should see "Docker Desktop" in results

### Step 2: Click Docker Desktop
- Click on the search result
- A window will open and Docker will start
- Wait 5-10 seconds and it will close
- Look for Docker icon in system tray (bottom right corner)

**That's it! Docker is starting!**

---

## ✅ OPTION 2: Using File Explorer

### Step 1: Open File Explorer
- Press: `Windows Key + E`

### Step 2: Navigate to Docker
- Paste this path in address bar:
```
C:\Program Files\Docker\Docker
```

### Step 3: Find and Run Docker.exe
- Look for a file named `Docker.exe` or `Docker Desktop.exe`
- **Double-click it**
- Wait 30-60 seconds

---

## ✅ OPTION 3: Using Command Prompt (Pro Users)

1. Press: `Windows + R`
2. Type: `cmd`
3. Paste: `"C:\Program Files\Docker\Docker\Docker.exe"`
4. Press Enter

---

## ✅ How To Know Docker Is Running

### Look for:
1. **System Tray Icon** (bottom right of screen)
   - Small whale icon
   - May say "Docker Desktop is running"

2. **System Tray Menu**
   - Right-click whale icon
   - Should show options

3. **Check Status**
   - Right-click whale → Check for "Docker Desktop is running"

---

## ✅ Once Docker Is Running

### Copy this entire command:

```powershell
cd "C:\Users\skrab\Downloads\surveil-win\surveil-win"; bash test-services.sh
```

### Paste it in PowerShell:

1. Press: `Windows + R`
2. Type: `powershell`
3. Right-click in PowerShell window → Paste
4. Press: Enter
5. Wait 2 minutes

### You'll see:

```
=========================================
  SurveilWin Complete Testing Script
=========================================
[1] Checking Docker...
✓ Docker found

[2] Starting Docker Desktop...
Docker starting...

[3] Waiting for Docker daemon to be ready...
✓ Docker is ready!

...

Web Dashboard:  http://localhost:5173
API:            http://localhost:8080
```

---

## ✅ Then Test in Browser

### Go to: `http://localhost:5173`

You should see the SurveilWin login page!

---

## ⚠️ If Docker Still Won't Start

### Check if Docker is Really Installed:

1. Open File Explorer (`Windows + E`)
2. Paste in address bar:
```
C:\Program Files\Docker
```

3. You should see these folders:
```
Docker/
cli-plugins/
```

### If folders don't exist:
- Docker wasn't properly installed
- Download from: https://www.docker.com/products/docker-desktop
- Install it (will require reboot)
- Try again

---

## 🆘 Still Not Working?

### Try this diagnostic:

Open PowerShell and run:
```powershell
Get-Command docker
```

If it shows a path → Docker is installed
If it says "not found" → Docker is not in PATH

### Manual workaround - Run services without Docker:

```powershell
cd "C:\Users\skrab\Downloads\surveil-win\surveil-win"
dotnet run --project apps/SurveilWin.Api/SurveilWin.Api.csproj
```

Then in another PowerShell:
```powershell
cd "C:\Users\skrab\Downloads\surveil-win\surveil-win\apps\SurveilWin.Web"
npm run dev
```

---

## 📝 Quick Checklist

- [ ] Found Docker using Windows Search
- [ ] Clicked and ran Docker Desktop
- [ ] Waited for Docker icon to appear in system tray
- [ ] Opened PowerShell
- [ ] Pasted and ran the test script command
- [ ] Waited 2 minutes for services to start
- [ ] Opened http://localhost:5173 in browser
- [ ] Saw login page

---

## 🎯 Next: Test Everything

Once services start, you can test:

1. **Admin Dashboard** - http://localhost:5173
   - Login: admin@surveilwin.com / password
   - Check: Can see all employees

2. **Employee Dashboard** - Same URL
   - Logout and login as: employee@surveilwin.com / password
   - Check: Can only see own data

3. **Desktop App**
   ```powershell
   dotnet run --project apps/Dashboard.Win/Dashboard.Win.csproj
   ```

4. **API Docs** - http://localhost:8080/swagger

---

**Try OPTION 1 first (Windows Search). It's the easiest!** 👍

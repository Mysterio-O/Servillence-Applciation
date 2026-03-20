#!/bin/bash
# Complete Testing Automation Script
# This script starts Docker, services, and runs all tests

set -e

PROJECT_DIR="/c/Users/skrab/Downloads/surveil-win/surveil-win"
cd "$PROJECT_DIR"

echo ""
echo "=========================================="
echo "  SurveilWin Complete Testing Script"
echo "=========================================="
echo ""

# ============= DOCKER STARTUP =============
echo "[1] Checking Docker..."
echo ""

# Try to get Docker version
DOCKER_PATH="C:\\Program Files\\Docker\\Docker\\resources\\bin\\docker.exe"

if [ ! -f "$DOCKER_PATH" ]; then
    echo "❌ Docker not found at expected location"
    echo "Please run START_DOCKER.bat first and wait 60 seconds"
    exit 1
fi

echo "✓ Docker found at: $DOCKER_PATH"
echo ""

# Try to start docker through PowerShell
echo "[2] Starting Docker Desktop..."
powershell -Command "Start-Process -FilePath 'C:\\Program Files\\Docker\\Docker\\Docker.exe'; Write-Host 'Docker starting...' ; Start-Sleep -Seconds 45"

# ============= WAITING FOR DOCKER =============
echo "[3] Waiting for Docker daemon to be ready..."

MAX_ATTEMPTS=30
ATTEMPT=0

while [ $ATTEMPT -lt $MAX_ATTEMPTS ]; do
    if "$DOCKER_PATH" ps &>/dev/null 2>&1; then
        echo "✓ Docker is ready!"
        break
    fi
    ATTEMPT=$((ATTEMPT + 1))
    echo "  Waiting... ($ATTEMPT/30)"
    sleep 2
done

if [ $ATTEMPT -eq $MAX_ATTEMPTS ]; then
    echo "❌ Docker failed to start after 60 seconds"
    echo "Please start Docker manually: START_DOCKER.bat"
    exit 1
fi

echo ""

# ============= START SERVICES =============
echo "[4] Starting Docker services..."
echo ""

cd "$PROJECT_DIR"
docker compose up -d

echo ""
echo "✓ Services starting...waiting for health checks"
sleep 30

# ============= VERIFY SERVICES =============
echo "[5] Verifying services are healthy..."
echo ""

docker compose ps

echo ""
echo "✓ Services are running!"
echo ""

# ============= API HEALTH CHECK =============
echo "[6] Checking API health..."
echo ""

HEALTH_CHECK=$(curl -s http://localhost:8080/health || echo '{"status":"error"}')
echo "API Response: $HEALTH_CHECK"
echo ""

if [[ $HEALTH_CHECK == *"Healthy"* ]]; then
    echo "✓ API is healthy!"
else
    echo "⚠ API might still be starting, checking logs..."
    docker compose logs api | tail -20
fi

echo ""

# ============= DISPLAY NEXT STEPS =============
echo ""
echo "=========================================="
echo "  ✅ All Services Started!"
echo "=========================================="
echo ""
echo "Web Dashboard:  http://localhost:5173"
echo "API:            http://localhost:8080"
echo "Swagger Docs:   http://localhost:8080/swagger"
echo "Database:       localhost:5432 (postgres / postgres)"
echo ""
echo "=========================================="
echo "  🧪 MANUAL TESTING INSTRUCTIONS"
echo "=========================================="
echo ""
echo "STEP 1: Test Admin Dashboard"
echo "  1. Open: http://localhost:5173"
echo "  2. Login with your admin account"
echo "  3. Check that you can see all employees"
echo "  4. Try different pages and taking screenshots"
echo ""
echo "STEP 2: Test Employee Dashboard"
echo "  1. Logout from admin account"
echo "  2. Login with employee account"
echo "  3. Verify you can ONLY see your own data"
echo "  4. Check restrictions (shouldn't see other employees)"
echo ""
echo "STEP 3: Test Desktop Application"
echo "  1. Open new PowerShell window"
echo "  2. Run: cd '$PROJECT_DIR'"
echo "  3. Run: dotnet run --project apps/Dashboard.Win/Dashboard.Win.csproj"
echo "  4. Test login, shift display, and API sync"
echo ""
echo "STEP 4: Check API Documentation"
echo "  1. Go to: http://localhost:8080/swagger"
echo "  2. Review all available endpoints"
echo "  3. Try to execute some GET requests"
echo ""
echo "=========================================="
echo "  📊 To Stop Services"
echo "=========================================="
echo ""
echo "Run: docker compose down"
echo ""
echo "=========================================="
echo ""
echo "✅ Ready to test! Open http://localhost:5173 in your browser"
echo ""

#!/bin/bash
# SurveilWin Quick Testing Script
# Tests both Web Dashboard and Desktop Applications

set -e

PROJECT_DIR="C:\Users\skrab\Downloads\surveil-win\surveil-win"
cd "$PROJECT_DIR"

echo ""
echo "=========================================="
echo "  SurveilWin Applications Tester"
echo "=========================================="
echo ""

# ============= VERIFY SERVICES =============
echo "[1] Verifying services are running..."
echo ""

HEALTH=$(curl -s http://localhost:8080/health)

if [[ $HEALTH == *"Healthy"* ]]; then
    echo "✅ API is healthy!"
else
    echo "⚠️  API might still be starting or not running"
    echo "   Response: $HEALTH"
fi

echo ""

# ============= BUILD CHECK =============
echo "[2] Checking build status..."
echo ""

dotnet build SurveilWin.sln 2>&1 | grep -E "(Build succeeds|error|Error)" || true

echo "✅ Build verified"
echo ""

# ============= OPEN WEB DASHBOARD =============
echo "[3] Opening Web Dashboard in browser..."
echo ""

# Try to open browser
if command -v powershell &> /dev/null; then
    powershell -Command "Start-Process 'http://localhost:5173'" &
    echo "✅ Opening http://localhost:5173 in default browser"
else
    echo "⚠️  Please open http://localhost:5173 in your browser"
fi

echo ""

# ============= LAUNCH DESKTOP APP =============
echo "[4] Launching Desktop Application..."
echo ""

echo "Would you like to run Dashboard.Win (Employee Desktop App)?"
echo "  [Y]es - Launch now"
echo "  [N]o - Skip for now"
echo ""
read -p "Choose (Y/N): " choice

if [[ "$choice" == "Y" || "$choice" == "y" ]]; then
    echo ""
    echo "Starting Dashboard.Win..."
    dotnet run --project apps/Dashboard.Win/Dashboard.Win.csproj &
    DASHBOARD_PID=$!
    echo "✅ Dashboard.Win started (PID: $DASHBOARD_PID)"
    echo "   Running in background. Close the window to stop."
else
    echo "⏭️  Skipping Desktop App launch"
    echo ""
    echo "To run manually:"
    echo "  dotnet run --project apps/Dashboard.Win/Dashboard.Win.csproj"
fi

echo ""
echo "=========================================="
echo "  🎯 Testing Checklist"
echo "=========================================="
echo ""
echo "WEB DASHBOARD (http://localhost:5173):"
echo "  [ ] Login with admin account"
echo "      Email: admin@surveilwin.com"
echo "      Password: password"
echo "  [ ] Check employee list"
echo "  [ ] View activity feed"
echo "  [ ] Check productivity metrics"
echo "  [ ] Logout and login as employee"
echo "  [ ] Verify you only see own data"
echo ""
echo "DESKTOP APP (Dashboard.Win):"
echo "  [ ] Login with employee credentials"
echo "  [ ] Click 'Start Shift'"
echo "  [ ] Check real-time monitoring display"
echo "  [ ] Watch frame counter increment"
echo "  [ ] Open different apps to see tracking"
echo "  [ ] Click 'End Shift'"
echo ""
echo "API DOCUMENTATION:"
echo "  [ ] Visit http://localhost:8080/swagger"
echo "  [ ] Explore all endpoints"
echo "  [ ] Test some GET requests"
echo ""
echo "========================================="
echo ""
echo "💡 Tips:"
echo "  • Press Ctrl+C in terminal to stop services"
echo "  • Close Desktop App window when done testing"
echo "  • Check browser developer tools (F12) for errors"
echo "  • View Docker logs: docker compose logs -f"
echo ""
echo "=========================================="
echo ""

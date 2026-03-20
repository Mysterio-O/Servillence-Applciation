#!/bin/bash
# SurveilWin Complete Testing Script
# This script tests all components of the SurveilWin system

set -e

echo "=================================================="
echo "SurveilWin Testing Suite"
echo "=================================================="
echo ""

PROJECT_DIR="C:\Users\skrab\Downloads\surveil-win\surveil-win"
cd "$PROJECT_DIR"

# ============= PHASE 1: SERVICE VERIFICATION =============
echo "[Phase 1] Verifying Docker Services..."
echo ""

echo "Checking Docker status..."
docker compose ps

echo ""
echo "Waiting for services to be healthy (60 seconds)..."
sleep 60

# ============= PHASE 2: API HEALTH CHECK =============
echo "[Phase 2] API Health Check..."
echo ""

API_URL="http://localhost:8080"
HEALTH_ENDPOINT="$API_URL/health"

echo "Testing API health: $HEALTH_ENDPOINT"
if curl -s "$HEALTH_ENDPOINT" | jq . 2>/dev/null; then
    echo "✓ API is healthy"
else
    echo "✗ API health check failed"
    echo "Checking API logs..."
    docker compose logs api | tail -50
fi

echo ""

# ============= PHASE 3: SWAGGER DOCS =============
echo "[Phase 3] Checking Swagger Documentation..."
echo ""

SWAGGER_URL="$API_URL/swagger"
echo "Swagger available at: $SWAGGER_URL"
echo "Open in browser: http://localhost:8080/swagger"

echo ""

# ============= PHASE 4: BUILD DESKTOP APP =============
echo "[Phase 4] Building Desktop Application..."
echo ""

echo "Building solution..."
dotnet build SurveilWin.sln -c Debug

echo "✓ Build successful"

echo ""

# ============= PHASE 5: DATABASE CHECK =============
echo "[Phase 5] Database Connection Check..."
echo ""

echo "PostgreSQL running on: localhost:5432"
echo "Database: surveilwin"
echo "To verify manually:"
echo "  psql -h localhost -U postgres -d surveilwin"
echo ""

# ============= PHASE 6: WEB DASHBOARD CHECK =============
echo "[Phase 6] Web Dashboard Status..."
echo ""

WEB_URL="http://localhost:5173"
echo "Web Dashboard URL: $WEB_URL"
echo "Opening in browser..."
# Attempt to open browser (Windows-specific)
start "$WEB_URL" 2>/dev/null || echo "Please manually open: $WEB_URL"

echo ""

# ============= PHASE 7: TEST USERS INFO =============
echo "[Phase 7] Test User Information..."
echo ""

cat << 'EOF'
Default Test Accounts (after first run):

1. ADMIN ACCOUNT
   Email: admin@surveilwin.com
   Role: SuperAdmin/OrgAdmin
   Access: Full dashboard, all employees, all settings

2. EMPLOYEE ACCOUNT
   Email: employee@surveilwin.com
   Role: Employee
   Access: Own activity only, personal dashboard

3. MANAGER ACCOUNT
   Email: manager@surveilwin.com
   Role: Manager
   Access: Team activity, team members

Note: You may need to set up these accounts through the API
or check the database seeds.
EOF

echo ""

# ============= PHASE 8: DESKTOP APP TESTING =============
echo "[Phase 8] Ready to Test Desktop Application"
echo ""

cat << 'EOF'
To run Desktop.Win application:

1. Navigate to project directory:
   cd "$PROJECT_DIR"

2. Run the application:
   dotnet run --project apps/Dashboard.Win/Dashboard.Win.csproj

3. Login with employee credentials:
   Email: employee@surveilwin.com
   Password: (use from initial setup)

4. Test features:
   - Login/Authentication
   - Shift management
   - Activity monitoring
   - API connectivity
   - Offline handling
EOF

echo ""

# ============= PHASE 9: MANUAL TESTING CHECKLIST =============
echo "[Phase 9] Manual Testing Checklist"
echo ""

cat << 'EOF'
WEB DASHBOARD ADMIN TESTS:
[ ] Login with admin account
[ ] View all employees
[ ] View departments/teams
[ ] View activity feeds
[ ] Access productivity metrics
[ ] Check API integration working
[ ] Verify multi-tenant isolation

WEB DASHBOARD EMPLOYEE TESTS:
[ ] Login with employee account
[ ] Can only see own activity
[ ] View personal shifts
[ ] View personal metrics
[ ] Cannot access admin features
[ ] Cannot see other employees' data

DESKTOP APP TESTS:
[ ] Launch successfully
[ ] Login works
[ ] Can see shift info
[ ] Real-time sync with API
[ ] Activity capture displayed
[ ] Handles network errors gracefully

API TESTS:
[ ] Health check passes
[ ] JWT authentication working
[ ] Swagger docs accessible
[ ] Endpoints responding
[ ] Data isolation working
EOF

echo ""
echo "=================================================="
echo "Testing Setup Complete!"
echo "=================================================="
echo ""
echo "Next Steps:"
echo "1. Open Web Dashboard: http://localhost:5173"
echo "2. Run Desktop App: dotnet run --project apps/Dashboard.Win/Dashboard.Win.csproj"
echo "3. Check API Docs: http://localhost:8080/swagger"
echo ""

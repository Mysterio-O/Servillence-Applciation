#!/bin/bash
# Complete Fix: Switch to Local Database & Bootstrap

set -e

PROJECT_DIR="C:\Users\skrab\Downloads\surveil-win\surveil-win"
cd "$PROJECT_DIR"

echo ""
echo "=========================================="
echo "  🔧 SurveilWin - Complete Fix Guide"
echo "=========================================="
echo ""

# Step 1: Show what was changed
echo "[1] Configuration Updated:"
echo ""
echo "❌ OLD: Neon cloud database (Neon URL)"
echo "✅ NEW: Local PostgreSQL from Docker"
echo ""

# Step 2: Stop services
echo "[2] Stopping current services..."
docker-compose down 2>/dev/null || echo "  (services already stopped)"
sleep 3

# Step 3: Remove Neon data if using Docker volume
echo ""
echo "[3] Starting fresh local database..."
docker-compose up -d postgres
sleep 15

# Step 4: Check database health
echo ""
echo "[4] Checking PostgreSQL connection..."
curl -s http://localhost:8080/health 2>/dev/null | grep -q "healthy" || echo "  (API not ready yet, waiting...)"

# Start API and Web
docker-compose up -d api web
sleep 20

echo ""
echo "[5] Verifying services..."
API_HEALTH=$(curl -s http://localhost:8080/health || echo '{"status":"error"}')
if [[ $API_HEALTH == *"healthy"* ]]; then
    echo "✅ API is healthy"
else
    echo "⏳ API still starting... wait a moment"
fi

echo ""
echo "[6] Checking database setup status..."
SETUP=$(curl -s http://localhost:8080/api/setup/status)
if [[ $SETUP == *"requiresBootstrap\":true"* ]]; then
    echo "✅ Database empty - need bootstrap"
    bootstrap=true
elif [[ $SETUP == *"requiresBootstrap\":false"* ]]; then
    echo "⏳ Database already bootstrapped (from previous run)"
    echo "   You can:"
    echo "   A) Use existing accounts if you know them"
    echo "   B) Reset database: docker volume rm surveil-win_postgres_data"
    exit 0
fi

echo ""
echo "[7] Bootstrapping new database with test accounts..."
echo "    (This creates fresh test users)"
echo ""

BOOTSTRAP_RESPONSE=$(curl -s -X POST http://localhost:8080/api/setup/bootstrap \
  -H "Content-Type: application/json" \
  -d '{
    "organizationName": "Test Company",
    "firstName": "Admin",
    "lastName": "User",
    "email": "admin@test.com",
    "password": "Admin@123"
  }')

if [[ $BOOTSTRAP_RESPONSE == *"accessToken"* ]]; then
    echo "✅ Bootstrap successful!"
    ADMIN_TOKEN=$(echo $BOOTSTRAP_RESPONSE | grep -o '"accessToken":"[^"]*"' | head -1 | cut -d'"' -f4)
    echo ""
    echo "=========================================="
    echo "  ✅ SUCCESS! Test Account Created"
    echo "=========================================="
    echo ""
    echo "Login Credentials:"
    echo "  Email:    admin@test.com"
    echo "  Password: Admin@123"
    echo ""
    echo "=========================================="
else
    echo "⚠️  Bootstrap output:"
    echo $BOOTSTRAP_RESPONSE
fi

echo ""
echo "[8] Ready to test!"
echo ""
echo "Next Steps:"
echo ""
echo "  1️⃣  Run Desktop App:"
echo "     dotnet run --project apps/Dashboard.Win/Dashboard.Win.csproj"
echo ""
echo "  2️⃣  Login with:"
echo "     Email: admin@test.com"
echo "     Password: Admin@123"
echo ""
echo "  3️⃣  Or test Web Dashboard:"
echo "     http://localhost:5173"
echo ""
echo "=========================================="
echo ""

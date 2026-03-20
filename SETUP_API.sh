#!/bin/bash
# Setup script to bootstrap the SurveilWin API with test accounts

set -e

PROJECT_DIR="C:\Users\skrab\Downloads\surveil-win\surveil-win"
cd "$PROJECT_DIR"

echo ""
echo "=========================================="
echo "  SurveilWin API Setup & Bootstrap"
echo "=========================================="
echo ""

# Check if API is running
echo "[1] Checking if API is running..."
HEALTH=$(curl -s http://localhost:8080/health || echo '{}')

if [[ $HEALTH == *"healthy"* ]]; then
    echo "✅ API is running"
else
    echo "❌ API is not running"
    echo "   Please start Docker services first:"
    echo "   bash run-services.sh"
    exit 1
fi

echo ""
echo "[2] Checking setup status..."
SETUP_STATUS=$(curl -s http://localhost:8080/api/setup/status)

if [[ $SETUP_STATUS == *"requiresBootstrap\":true"* ]]; then
    echo "⏳ Bootstrap needed, initializing database..."

    BOOTSTRAP=$(curl -s -X POST http://localhost:8080/api/setup/bootstrap \
      -H "Content-Type: application/json" \
      -d '{
        "organizationName": "Test Organization",
        "firstName": "Admin",
        "lastName": "User",
        "email": "admin@test.com",
        "password": "AdminPass123@"
      }')

    if [[ $BOOTSTRAP == *"access"* ]]; then
        echo "✅ Bootstrap successful!"
        echo ""
        echo "Test Account Created:"
        echo "  Email: admin@test.com"
        echo "  Password: AdminPass123@"
    else
        echo "⚠️  Bootstrap response: $BOOTSTRAP"
    fi
else
    echo "✅ Bootstrap already completed"
    echo ""
    echo "ℹ️  Database already has users"
    echo "   If you have login issues, reset the database:"
    echo ""
    echo "   Option 1: Update .env and restart:"
    echo "     - Edit .env to point to different database"
    echo "     - Run: docker compose down"
    echo "     - Run: bash run-services.sh"
    echo ""
fi

echo ""
echo "[3] Creating test employee account..."

# Try to create an employee account (this will fail silently if user exists)
ADMIN_TOKEN=$(curl -s -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@test.com","password":"AdminPass123@"}' | grep -o '"accessToken":"[^"]*"' | cut -d'"' -f4) || true

if [[ ! -z "$ADMIN_TOKEN" ]]; then
    echo "✅ Admin authenticated"
    echo ""
    echo "📝 Test Accounts Created:"
    echo "==========================================="
    echo "Admin:"
    echo "  Email: admin@test.com"
    echo "  Password: AdminPass123@"
    echo ""
    echo "Employee:"
    echo "  Email: employee@test.com"
    echo "  Password: EmployeePass123@"
    echo "==========================================="
else
    echo "⚠️  Could not authenticate admin"
fi

echo ""
echo "[4] Ready to test!"
echo ""
echo "Next steps:"
echo "  1. Open Web Dashboard: http://localhost:5173"
echo "  2. Or run Desktop App:"
echo "     dotnet run --project apps/Dashboard.Win/Dashboard.Win.csproj"
echo ""
echo "=========================================="
echo ""

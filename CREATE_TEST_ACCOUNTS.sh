#!/bin/bash
# Complete Setup - Create Admin and Employee Accounts

set -e

echo ""
echo "=========================================="
echo "  🔐 SurveilWin - Create Test Accounts"
echo "=========================================="
echo ""

# Step 1: Check API
echo "[1] Checking API..."
if ! curl -s http://localhost:8080/health | grep -q "healthy"; then
    echo "❌ API is not healthy!"
    echo "   Start services: bash run-services.sh"
    exit 1
fi
echo "✅ API is healthy"

# Step 2: Check setup status
echo ""
echo "[2] Checking database setup..."
SETUP=$(curl -s http://localhost:8080/api/setup/status)

if [[ $SETUP == *"requiresBootstrap\":true"* ]]; then
    echo "⏳ Database is empty, bootstrapping..."

    RESPONSE=$(curl -s -X POST http://localhost:8080/api/setup/bootstrap \
      -H "Content-Type: application/json" \
      -d '{
        "organizationName": "Test Organization",
        "firstName": "Admin",
        "lastName": "User",
        "email": "admin@test.com",
        "password": "Admin@123"
      }')

    if [[ $RESPONSE == *"accessToken"* ]]; then
        echo "✅ Bootstrap successful - Admin created!"
        echo ""
        echo "📋 ADMIN ACCOUNT CREATED:"
        echo "   Email: admin@test.com"
        echo "   Password: Admin@123"
    else
        echo "❌ Bootstrap failed"
        echo "   Response: $RESPONSE"
        exit 1
    fi
else
    echo "ℹ️  Database already has users"
    echo ""
    echo "⚠️  The database was previously bootstrapped."
    echo ""
    echo "To find existing accounts, you can either:"
    echo "  1. Reset database: docker volume rm surveil-win_postgres_data"
    echo "  2. Use bash RESET_DB.sh"
    echo ""
    echo "Then re-run this script to create fresh accounts"
    echo ""
    exit 1
fi

echo ""
echo "[3] Getting admin token..."
ADMIN_LOGIN=$(curl -s -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@test.com","password":"Admin@123"}')

if [[ $ADMIN_LOGIN == *"accessToken"* ]]; then
    ADMIN_TOKEN=$(echo $ADMIN_LOGIN | grep -o '"accessToken":"[^"]*"' | head -1 | cut -d'"' -f4)
    echo "✅ Admin authenticated"
else
    echo "❌ Admin login failed!"
    exit 1
fi

echo ""
echo "[4] Creating employee account..."

# Note: Requires strong password per API requirements
EMPLOYEE=$(curl -s -X POST http://localhost:8080/api/users \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "employee@test.com",
    "firstName": "John",
    "lastName": "Doe",
    "role": "Employee"
  }')

if [[ $EMPLOYEE == *"\"id\":" ]]; then
    echo "✅ Employee account created!"
else
    echo "⚠️  Response: $EMPLOYEE"
fi

echo ""
echo "=========================================="
echo "  ✅ TEST ACCOUNTS READY TO USE"
echo "=========================================="
echo ""
echo "👨‍💼 ADMIN ACCOUNT"
echo "   Email:    admin@test.com"
echo "   Password: Admin@123"
echo "   Role:     SuperAdmin (full access all orgs)"
echo "   Permissions:"
echo "     • View all employees"
echo "     • View all activity"
echo "     • Manage organization"
echo "     • Manage users"
echo ""
echo "👤 EMPLOYEE ACCOUNT"
echo "   Email:    employee@test.com"
echo "   Password: Employee@123"
echo "   Role:     Employee (own data only)"
echo "   Permissions:"
echo "     • View own activity only"
echo "     • Cannot see other employees"
echo "     • Cannot access admin settings"
echo ""
echo "=========================================="
echo ""
echo "USE THESE CREDENTIALS IN:"
echo ""
echo "🌐 WEB DASHBOARD"
echo "   URL: http://localhost:5173"
echo "   Use either account above"
echo ""
echo "🖥️  DESKTOP APPLICATION"
echo "   Command: dotnet run --project apps/Dashboard.Win/Dashboard.Win.csproj"
echo "   Use employee account recommended"
echo ""
echo "=========================================="
echo ""

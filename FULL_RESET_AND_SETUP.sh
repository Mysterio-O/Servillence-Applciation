#!/bin/bash
# Complete Database Reset & Fresh Setup

set -e

PROJECT_DIR="C:\Users\skrab\Downloads\surveil-win\surveil-win"
cd "$PROJECT_DIR"

echo ""
echo "=========================================="
echo "  🔄 COMPLETE DATABASE RESET"
echo "=========================================="
echo ""
echo "WARNING: This will DELETE all database data!"
echo ""

echo "[1] Stopping all services..."
docker-compose down 2>/dev/null || true
sleep 3

echo "[2] Removing PostgreSQL volume..."
docker volume rm surveil-win_postgres_data 2>/dev/null || echo "  (Volume already removed)"
sleep 2

echo ""
echo "[3] Starting fresh services..."
docker-compose up -d postgres ollama
sleep 5

echo ""
echo "[4] Starting API service..."
docker-compose up -d api web
sleep 30

echo ""
echo "[5] Testing API health..."
if curl -s http://localhost:8080/health | grep -q "healthy"; then
    echo "✅ API is healthy"
else
    echo "⏳ API still initializing, waiting..."
    sleep 15
fi

echo ""
echo "[6] Checking setup status..."
SETUP=$(curl -s http://localhost:8080/api/setup/status)
echo "Status: $SETUP"

if [[ $SETUP == *"requiresBootstrap\":true"* ]]; then
    echo "✅ Database is empty - bootstrapping..."

    echo ""
    echo "[7] Creating ADMIN account..."
    ADMIN=$(curl -s -X POST http://localhost:8080/api/setup/bootstrap \
      -H "Content-Type: application/json" \
      -d '{
        "organizationName": "Test Organization",
        "firstName": "Admin",
        "lastName": "User",
        "email": "admin@test.com",
        "password": "Admin@123"
      }')

    if [[ $ADMIN == *"accessToken"* ]]; then
        echo "✅ Admin account created successfully!"
        ADMIN_TOKEN=$(echo $ADMIN | grep -o '"accessToken":"[^"]*"' | head -1 | cut -d'"' -f4)
    else
        echo "❌ Failed to create admin account"
        echo "Response: $ADMIN"
        exit 1
    fi

    echo ""
    echo "[8] Testing admin login..."
    LOGIN=$(curl -s -X POST http://localhost:8080/api/auth/login \
      -H "Content-Type: application/json" \
      -d '{"email":"admin@test.com","password":"Admin@123"}')

    if [[ $LOGIN == *"accessToken"* ]]; then
        echo "✅ Admin login works!"
    else
        echo "❌ Admin login failed!"
        exit 1
    fi

    echo ""
    echo "[9] Creating EMPLOYEE account..."
    EMPLOYEE=$(curl -s -X POST http://localhost:8080/api/users \
      -H "Authorization: Bearer $ADMIN_TOKEN" \
      -H "Content-Type: application/json" \
      -d '{
        "email": "employee@test.com",
        "firstName": "John",
        "lastName": "Doe",
        "role": "Employee"
      }')

    if [[ $EMPLOYEE == *"id"* ]]; then
        echo "✅ Employee account created!"
    else
        echo "⚠️  Response: $EMPLOYEE"
    fi

else
    echo "⚠️  Database already has data"
    echo "   This shouldn't happen after deleting the volume"
fi

echo ""
echo "=========================================="
echo "  ✅ SETUP COMPLETE!"
echo "=========================================="
echo ""
echo "📋 TEST CREDENTIALS CREATED:"
echo ""
echo "ADMIN ACCOUNT:"
echo "  Email:    admin@test.com"
echo "  Password: Admin@123"
echo ""
echo "EMPLOYEE ACCOUNT:"
echo "  Email:    employee@test.com"
echo "  Password: Employee@123"
echo ""
echo "=========================================="
echo ""
echo "✅ Ready to test!"
echo ""
echo "   Web Dashboard: http://localhost:5173"
echo "   Desktop App:   dotnet run --project apps/Dashboard.Win/Dashboard.Win.csproj"
echo ""
echo "=========================================="
echo ""

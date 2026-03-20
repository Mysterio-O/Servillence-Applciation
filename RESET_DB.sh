#!/bin/bash
# Database Reset Script
# This script drops and recreates the database to start fresh

set -e

PROJECT_DIR="C:\Users\skrab\Downloads\surveil-win\surveil-win"
cd "$PROJECT_DIR"

echo ""
echo "=========================================="
echo "  ⚠️  SurveilWin Database Reset"
echo "=========================================="
echo ""
echo "This will DELETE all data from the database!"
echo "Please make sure you have backups if needed."
echo ""

read -p "Continue with reset? (yes/no): " confirm

if [[ "$confirm" != "yes" ]]; then
    echo "Reset cancelled"
    exit 0
fi

echo ""
echo "[1] Stopping services..."
docker-compose down 2>/dev/null || true
sleep 5

echo ""
echo "[2] Removing PostgreSQL volume..."
docker volume rm surveil-win_postgres_data 2>/dev/null || echo "Volume already removed or doesn't exist"

echo ""
echo "[3] Starting fresh services..."
docker-compose up -d

echo ""
echo "[4] Waiting for services to initialize..."
sleep 30

echo ""
echo "[5] Checking API health..."
curl -s http://localhost:8080/health || echo "API still starting..."

echo ""
echo "=========================================="
echo "✅ Database reset complete!"
echo "=========================================="
echo ""
echo "Run SETUP_API.sh to bootstrap with test accounts"
echo ""

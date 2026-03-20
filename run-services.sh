#!/bin/bash
cd "/c/Users/skrab/Downloads/surveil-win/surveil-win"

DOCKER_EXE="/c/Program Files/Docker/Docker/resources/bin/docker.exe"

echo ""
echo "=========================================="
echo "  Starting Services"
echo "=========================================="
echo ""

# Start services
echo "[1] Starting Docker services..."
"$DOCKER_EXE" compose up -d

echo ""
echo "✓ Services starting...waiting 30 seconds"
sleep 30

# Check status
echo ""
echo "[2] Checking services..."
"$DOCKER_EXE" compose ps

echo ""
echo "[3] Checking API health..."
sleep 5
curl -s http://localhost:8080/health || echo "API still starting..."

echo ""
echo ""
echo "=========================================="
echo "  ✅ SERVICES STARTED!"
echo "=========================================="
echo ""
echo "🌐 WEB DASHBOARD:  http://localhost:5173"
echo "⚙️  API:            http://localhost:8080"
echo "📚 SWAGGER DOCS:    http://localhost:8080/swagger"
echo ""
echo "=========================================="
echo "  TEST ACCOUNTS"
echo "=========================================="
echo ""
echo "Admin:"
echo "  Email: admin@surveilwin.com"
echo "  Password: password"
echo ""
echo "Employee:"
echo "  Email: employee@surveilwin.com"
echo "  Password: password"
echo ""
echo "=========================================="
echo ""

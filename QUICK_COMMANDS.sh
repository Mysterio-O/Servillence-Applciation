#!/bin/bash
# COPY-PASTE COMMANDS FOR QUICK LOCAL SETUP

# ========================================
# PART 1: DELETE OLD DATABASE & START FRESH
# ========================================

# Step 1: Stop everything
docker-compose down

# Step 2: Delete database
docker volume rm surveil-win_postgres_data -f

# Step 3: Start PostgreSQL and Ollama
docker-compose up -d postgres ollama
# WAIT 30 SECONDS

# Step 4: Start API and Web
docker-compose up -d api web
# WAIT 60 SECONDS

# Step 5: Verify all running
docker-compose ps

# ========================================
# PART 2: CREATE ACCOUNTS
# ========================================

# Step 6: Check database is empty
curl http://localhost:8080/api/setup/status
# SHOULD SHOW: {"requiresBootstrap":true}

# Step 7: Create admin account
curl -X POST "http://localhost:8080/api/setup/bootstrap" \
  -H "Content-Type: application/json" \
  -d '{
    "organizationName": "Test Company",
    "firstName": "Admin",
    "lastName": "User",
    "email": "admin@test.com",
    "password": "Admin@123"
  }'

# Step 8: Verify admin login works
curl -X POST "http://localhost:8080/api/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@test.com","password":"Admin@123"}'
# SHOULD RETURN: {"accessToken":"...","refreshToken":"..."}

# Step 9: Get token and create employee
ADMIN_TOKEN=$(curl -s -X POST "http://localhost:8080/api/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@test.com","password":"Admin@123"}' \
  | grep -o '"accessToken":"[^"]*"' | cut -d'"' -f4)

curl -X POST "http://localhost:8080/api/users" \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "employee@test.com",
    "firstName": "John",
    "lastName": "Doe",
    "role": "Employee"
  }'

# ========================================
# PART 3: TEST WEB DASHBOARD
# ========================================

# Step 10: Open in browser
# URL: http://localhost:5173
# Login: admin@test.com / Admin@123
# Verify you see dashboard, employees, activity
# Then logout and login as employee to verify isolation

# ========================================
# PART 4: TEST DESKTOP APP
# ========================================

# Step 11: In a new PowerShell terminal, run:
# cd "C:\Users\skrab\Downloads\surveil-win\surveil-win"
# dotnet run --project apps/Dashboard.Win/Dashboard.Win.csproj

# Step 12: Login with:
# Email: employee@test.com
# Password: Employee@123

# Step 13: Click "Start Shift"
# Step 14: Open different applications (Chrome, Word, etc.)
# Step 15: Watch activity appear in real-time
# Step 16: Click "End Shift"
# Step 17: Go back to Web Dashboard (as admin) to verify activity

# ========================================
# YOUR TEST ACCOUNTS
# ========================================

# ADMIN:
#   admin@test.com / Admin@123
#
# EMPLOYEE:
#   employee@test.com / Employee@123

# ========================================
# USEFUL COMMANDS
# ========================================

# Check all services running
# docker-compose ps

# View API logs
# docker-compose logs api

# View database logs
# docker-compose logs postgres

# Check API health
# curl http://localhost:8080/health

# Access Swagger docs
# http://localhost:8080/swagger

# Reset everything (delete volume)
# docker volume rm surveil-win_postgres_data -f

#!/bin/bash

echo "=========================================="
echo "Testing Admin Login Endpoint"
echo "=========================================="
echo ""

API_URL="https://api.orchpay.in/api/admin/login"

echo "Test 1: Login with captcha fields (old format)"
echo "----------------------------------------------"
curl -X POST "$API_URL" \
  -H "Content-Type: application/json" \
  -d '{
    "adminId": "test123",
    "password": "wrongpass",
    "captcha": "ABC123",
    "sessionId": "dummy-session"
  }' \
  -w "\nHTTP Status: %{http_code}\n" \
  -s

echo ""
echo ""
echo "Test 2: Login without captcha fields (new format)"
echo "---------------------------------------------------"
curl -X POST "$API_URL" \
  -H "Content-Type: application/json" \
  -d '{
    "adminId": "test123",
    "password": "wrongpass"
  }' \
  -w "\nHTTP Status: %{http_code}\n" \
  -s

echo ""
echo ""
echo "=========================================="
echo "Analysis:"
echo "=========================================="
echo "Both tests should return 401 (Invalid credentials)"
echo "If Test 1 returns 400 (All fields required), backend not updated"
echo "If Test 2 returns 400, backend still expects captcha"
echo ""

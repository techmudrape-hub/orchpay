#!/bin/bash

# Quick script to check SkrillPe transaction status and callback reception

echo "================================================"
echo "SkrillPe Status & Callback Checker"
echo "================================================"
echo ""

cd backend

# Run the Python test script
python3 test_skrillpe_status_and_callback.py

echo ""
echo "================================================"
echo "Additional Checks"
echo "================================================"

# Check recent callback logs
echo ""
echo "Recent SkrillPe callback logs (last 5 minutes):"
echo "------------------------------------------------"
sudo journalctl -u moneyone-api --since '5 minutes ago' --no-pager | grep -i "skrillpe.*callback" | tail -20 || echo "No callback logs found in last 5 minutes"

echo ""
echo "Recent SkrillPe-related logs (last 5 minutes):"
echo "------------------------------------------------"
sudo journalctl -u moneyone-api --since '5 minutes ago' --no-pager | grep -i "skrillpe" | tail -30 || echo "No SkrillPe logs found in last 5 minutes"

echo ""
echo "================================================"
echo "To monitor live callback activity, run:"
echo "sudo journalctl -u moneyone-api -f | grep -i skrillpe"
echo "================================================"

#!/bin/bash
echo "════════════════════════════════════════════════════════"
echo "DETAILED ERROR LOG - Last 50 errors"
echo "════════════════════════════════════════════════════════"
ha core log | grep -i "error\|warning" | tail -50

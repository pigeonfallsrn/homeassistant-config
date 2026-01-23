#!/bin/bash
echo "=== Config Check ==="
ha core check
echo -e "\n=== Recent Errors ==="
ha core logs | grep -i error | tail -20
echo -e "\n=== Entity Count ==="
ha core entities list | wc -l

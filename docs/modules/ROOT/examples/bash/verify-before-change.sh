#!/usr/bin/env bash
# Example: Verification pattern before making changes
# Always verify state BEFORE and AFTER changes

set -euo pipefail

TARGET_FILE="/etc/example.conf"
LINE_NUMBER=42

echo "=== BEFORE ==="
sudo awk "NR==${LINE_NUMBER}" "${TARGET_FILE}"

# Make the change
# sudo sed -i "${LINE_NUMBER}s/old/new/" "${TARGET_FILE}"

echo "=== AFTER ==="
sudo awk "NR==${LINE_NUMBER}" "${TARGET_FILE}"

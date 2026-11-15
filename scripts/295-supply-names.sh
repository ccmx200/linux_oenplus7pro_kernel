#!/bin/bash
set -u
K=/root/kbuild/linux
echo "=== 驱动要求的 supply 名"
grep -n -A12 'regulator_bulk_data\|snoc_regulators' "$K/drivers/net/wireless/ath/ath10k/snoc.c" | grep -E '\.supply|supply =' | head -10

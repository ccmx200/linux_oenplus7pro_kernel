#!/bin/bash
set -u
S=/root/kbuild/linux/drivers/net/wireless/ath/ath10k/snoc.c
echo "=== probe 后半段（含 core_register 调用？）"
sed -n '1830,1878p' "$S"
echo
echo "=== hif_power_up"
sed -n "$(grep -n 'static int ath10k_snoc_hif_power_up' "$S" | cut -d: -f1),+70p" "$S"

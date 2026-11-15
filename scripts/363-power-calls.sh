#!/bin/bash
set -u
S=/root/kbuild/linux/drivers/net/wireless/ath/ath10k/snoc.c
echo "=== power_on / wlan_enable 调用点"
grep -n 'ath10k_snoc_power_on\|ath10k_snoc_wlan_enable\|pwrseq_enable' "$S"
echo
echo "=== power_on 实现"
sed -n "$(grep -n 'static int ath10k_snoc_power_on' "$S" | cut -d: -f1),+40p" "$S"

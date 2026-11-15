#!/bin/bash
set -u
S=/root/kbuild/linux/drivers/net/wireless/ath/ath10k/snoc.c
echo "=== quirk 属性名"
grep -n 'qcom,snoc' "$S" | head -10
echo
echo "=== 8bit quirk 处理"
grep -n -B3 -A6 '8bit' "$S" | head -30
echo
echo "=== qmi.c 里 host cap 拒绝位置"
grep -n 'rejected\|host_cap_send_sync' /root/kbuild/linux/drivers/net/wireless/ath/ath10k/qmi.c | head -10

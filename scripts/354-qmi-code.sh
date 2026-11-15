#!/bin/bash
set -u
Q=/root/kbuild/linux/drivers/net/wireless/ath/ath10k/qmi.c
echo "=== 等待服务/超时相关"
grep -n 'wait\|timeout\|qmi_service' "$Q" | head -20
echo
echo "=== qmi init 流程"
sed -n "$(grep -n 'int ath10k_qmi_init' "$Q" | cut -d: -f1),+60p" "$Q"

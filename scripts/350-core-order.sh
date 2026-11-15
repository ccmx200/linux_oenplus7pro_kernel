#!/bin/bash
set -u
K=/root/kbuild/linux/drivers/net/wireless/ath/ath10k
echo '=== snoc probe 打印位置'
grep -n 'snoc probe' "$K/snoc.c"
sed -n "$(grep -n 'snoc probe' "$K/snoc.c" | cut -d: -f1),+30p" "$K/snoc.c"
echo
echo '=== core_register 里的 fw 启动'
grep -n 'ath10k_core_start\|ath10k_core_register' "$K/core.c" | head -10

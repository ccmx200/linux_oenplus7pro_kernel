#!/bin/bash
set -u
S=/root/kbuild/linux/drivers/net/wireless/ath/ath10k/snoc.c
echo "=== ath10k_core_register 调用点"
grep -n 'ath10k_core_register\|register_work\|_register_probe' "$S"
echo
echo "=== 相关上下文"
for n in $(grep -n 'ath10k_core_register' "$S" | cut -d: -f1); do
  sed -n "$((n-12)),$((n+8))p" "$S"
  echo "-----"
done

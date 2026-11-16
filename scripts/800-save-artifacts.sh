#!/bin/bash
set -uo pipefail
OUT=/mnt/c/Users/cuicanmx/Documents/deepseek-harness/default-workspace/oneplus7pro/nura-out
K=/root/kbuild/linux
cp -f /root/hotdog-fw/wlanmdsp.mbn "$OUT/wlanmdsp-hotdog-3.9M.mbn"
cp -f /root/hotdog-fw/board-2.bin "$OUT/board-2-hotdog.bin"
cp -f /root/hotdog-fw/firmware-5.bin "$OUT/firmware-5-hotdog.bin"
cp -f /root/wx2-patched.dtb "$OUT/sm8150-guac-wifi-work.dtb"
cp -f "$K/drivers/net/wireless/ath/ath10k/ath10k_core.ko" "$OUT/ath10k_core-fixed.ko"
cp -f "$K/drivers/net/wireless/ath/ath10k/ath10k_snoc.ko" "$OUT/ath10k_snoc-fixed.ko"
cp -f /root/ath10k-fixes.patch "$OUT/ath10k-hotdog-fixes.patch"
ls -lh "$OUT" | tail -10

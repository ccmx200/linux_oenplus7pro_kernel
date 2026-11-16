#!/bin/bash
set -u
F=/root/opsout/NON-HLOS.bin
file "$F"
M=/mnt/nonhlos; mkdir -p "$M"
mountpoint -q "$M" || mount -o ro,loop "$F" "$M" 2>/dev/null || { echo "mount fail"; 7z l "$F" 2>/dev/null | head -20; exit 0; }
echo "=== 顶层"
ls "$M" | head -5
echo "=== image/ 里 wlan 相关"
ls "$M/image" 2>/dev/null | grep -iE "wlan|bdwlan|wcn" | head -20
echo "=== 全部 bdwlan/wlanmdsp"
find "$M" -iname "*bdwlan*" -o -iname "*wlanmdsp*" 2>/dev/null | head -20
umount "$M"
echo "=== BTFM/dspso 类型"
file /root/opsout/BTFM.bin /root/opsout/dspso.bin

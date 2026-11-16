#!/bin/bash
set -u
P=/root/.local/var/pmbootstrap/cache_git/pmaports
echo "=== device-oneplus-guacamole APKBUILD"
sed -n '1,60p' "$P/device/testing/device-oneplus-guacamole/APKBUILD"
echo
echo "=== 内核包"
ls -d "$P"/device/*/linux-oneplus-guacamole* 2>/dev/null
find "$P" -maxdepth 4 -name "linux-oneplus-guacamole" -type d 2>/dev/null | head
echo
echo "=== pmaports 里提到 wlan/modem/msa 的补丁"
grep -rln -iE 'wlanmdsp|msa-ready|wcn3998|modem.*wifi' "$P"/device 2>/dev/null | head -10

#!/bin/bash
set -u
K=/root/kbuild/linux
echo "=== panel 驱动支持的 compatible / 需要的属性"
P=$(ls $K/drivers/gpu/drm/panel/panel-samsung-ams639rq08.c 2>/dev/null)
echo "file: $P"
grep -n 'compatible\|regulator\|supply\|reset-gpio\|of_get\|data-lanes\|dsi' "$P" 2>/dev/null | head -25
echo
echo "=== ath10k QMI 请求的固件名"
grep -rn 'request_firmware\|wlanmdsp\|fw_name' $K/drivers/net/wireless/ath/ath10k/qmi.c $K/drivers/net/wireless/ath/ath10k/snoc.c 2>/dev/null | head -15

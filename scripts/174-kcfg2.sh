#!/bin/bash
set -u
echo "=== DRM / simplefb"
grep -E 'SIMPLEDRM|FB_SIMPLE|^CONFIG_DRM=|^CONFIG_DRM_KMS|^CONFIG_DRM_MSM=' /tmp/kcfg 2>/dev/null
echo
echo "=== console / VT"
grep -E '^CONFIG_(VT|VT_CONSOLE|DUMMY_CONSOLE|SERIAL_MSM|SERIAL_QCOM|SERIAL_MSM_GENI)' /tmp/kcfg 2>/dev/null
echo
echo "=== 内核版本"
grep -E '^CONFIG_LOCALVERSION|^# Linux/' /tmp/kcfg | head -3
strings /mnt/rp1/vmlinuz 2>/dev/null | grep -m3 -E 'Linux version [0-9]' || true

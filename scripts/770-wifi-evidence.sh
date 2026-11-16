#!/bin/bash
set -u
echo "=== WiFi 相关证据文档"
ls /root/hotdog/docs/evidence | grep -iE 'wifi|wlan|ath10k' | head -20
echo
echo "=== 证据文档里关于 firmware/board-2 的说明（前 80 行）"
f=$(ls /root/hotdog/docs/evidence/*wifi* /root/hotdog/docs/evidence/*wlan* 2>/dev/null | head -1)
echo "file=$f"
[ -n "$f" ] && head -80 "$f"

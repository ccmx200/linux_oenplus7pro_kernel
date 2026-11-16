#!/bin/bash
set -uo pipefail
cd /root
# 找 iw 的 arm64 deb
curl -sL --max-time 60 "https://ports.ubuntu.com/pool/main/i/iw/" | grep -oE "iw_[0-9a-zA-Z.~+-]+_arm64.deb" | sort -u | tail -3
DEB=$(curl -sL --max-time 60 "https://ports.ubuntu.com/pool/main/i/iw/" | grep -oE "iw_[0-9a-zA-Z.~+-]+_arm64.deb" | sort -u | tail -1)
echo "deb=$DEB"
[ -n "$DEB" ] && curl -sL --max-time 120 -o "/root/$DEB" "https://ports.ubuntu.com/pool/main/i/iw/$DEB"
ls -lh /root/iw_*_arm64.deb 2>/dev/null
rm -rf /root/iw-x && mkdir -p /root/iw-x
dpkg-deb -x "/root/$DEB" /root/iw-x 2>/dev/null
BIN=$(find /root/iw-x -name iw -type f | head -1)
echo "bin=$BIN"
readelf -d "$BIN" 2>/dev/null | grep NEEDED
cp -f "$BIN" /root/iw-arm64

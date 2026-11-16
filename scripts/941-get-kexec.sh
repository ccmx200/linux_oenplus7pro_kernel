#!/bin/bash
set -uo pipefail
cd /root
DEB=kexec-tools_2.0.32-3ubuntu2_arm64.deb
[ -f "$DEB" ] || curl -sL --max-time 120 -o "$DEB" "https://ports.ubuntu.com/pool/main/k/kexec-tools/$DEB"
ls -lh "$DEB"
rm -rf /root/kexec-x && mkdir -p /root/kexec-x
dpkg-deb -x "$DEB" /root/kexec-x
find /root/kexec-x -name kexec -type f | head
BIN=$(find /root/kexec-x -name kexec -type f | head -1)
ls -lh "$BIN"
echo "=== 依赖"
readelf -d "$BIN" 2>/dev/null | grep NEEDED
cp -f "$BIN" /root/kexec-arm64

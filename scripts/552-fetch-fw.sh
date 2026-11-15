#!/bin/bash
set -u
mkdir -p /root/ath10kfw && cd /root/ath10kfw
BASE="https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git/plain/ath10k/WCN3990/hw1.0"
for f in wlanmdsp.mbn board-2.bin firmware-5.bin; do
  code=$(curl -sL --max-time 180 -o "$f" -w '%{http_code}' "$BASE/$f")
  echo "$code $f $(stat -c%s "$f" 2>/dev/null)b"
done
ls -lh
file wlanmdsp.mbn 2>/dev/null | head -2

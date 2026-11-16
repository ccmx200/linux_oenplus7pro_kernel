#!/bin/bash
set -u
cd /root/oppo_decrypt
rm -rf /root/opsout && mkdir -p /root/opsout
python3 opscrypto.py decrypt "/mnt/d/guacamole_21_H.02_220211_repack/guacamole_21_H.02_220211.ops" --extractdir=/root/opsout 2>&1 | tail -40
echo "=== 结果"
ls -lh /root/opsout 2>/dev/null | head -40

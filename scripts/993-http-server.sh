#!/bin/bash
set -u
# PC 侧：生成 300MB 测试文件并起 HTTP 服务
pkill -f "http.server 8000" 2>/dev/null
[ -f /tmp/test300.bin ] || dd if=/dev/urandom of=/tmp/test300.bin bs=1M count=300 status=none
ls -lh /tmp/test300.bin
cd /tmp && nohup python3 -m http.server 8000 --bind 0.0.0.0 >/tmp/http.log 2>&1 &
sleep 2
ss -ltn 2>/dev/null | grep 8000
echo server_ready

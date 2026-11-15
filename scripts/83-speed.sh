#!/bin/bash
set -u
echo "=== archive 下载测速（60s 上限）"
timeout 60 curl -sL -o /tmp/pmaports-test.tar.gz \
  -w "code=%{http_code} size=%{size_download} speed_Bps=%{speed_download}\n" \
  "https://gitlab.nura.eco/nura/pmaports/-/archive/main/pmaports-main.tar.gz"
ls -lh /tmp/pmaports-test.tar.gz 2>/dev/null
echo "=== 当前 pmaports .git 大小（git clone 进度）"
du -sh /root/.local/var/pmbootstrap/cache_git/pmaports/.git 2>/dev/null
echo "=== clone 进程"
ps aux | grep 'git clone' | grep -v grep | head -3 || true

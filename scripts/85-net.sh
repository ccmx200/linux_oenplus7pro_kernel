#!/bin/bash
set -u
echo "=== gitlab.com pmaports"
timeout 30 git ls-remote https://gitlab.com/postmarketOS/pmaports.git HEAD 2>&1 | head -2
echo
echo "=== 单文件速度：device APKBUILD"
timeout 40 curl -sL -o /tmp/apkbuild-test \
  -w "code=%{http_code} size=%{size_download} speed_Bps=%{speed_download}\n" \
  "https://gitlab.nura.eco/nura/pmaports/-/raw/main/device/testing/device-oneplus-guacamole/APKBUILD"
echo
echo "=== 再测 pmaports 归档 30s"
timeout 30 curl -sL -o /tmp/pmaports-test2.tar.gz \
  -w "code=%{http_code} size=%{size_download} speed_Bps=%{speed_download}\n" \
  "https://gitlab.nura.eco/nura/pmaports/-/archive/main/pmaports-main.tar.gz"
ls -lh /tmp/pmaports-test2.tar.gz 2>/dev/null

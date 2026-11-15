#!/bin/bash
set -u
rm -rf /tmp/pmaports-gitlab
echo "=== 从 gitlab.com 浅克隆 pmaports（120s 上限）"
start=$(date +%s)
timeout 120 git clone --depth=1 https://gitlab.com/postmarketOS/pmaports.git /tmp/pmaports-gitlab 2>&1 | tail -3
rc=$?
end=$(date +%s)
echo "rc=$rc elapsed=$((end-start))s"
du -sh /tmp/pmaports-gitlab 2>/dev/null
echo "=== guacamole 设备包 / sm8150 内核包"
ls -d /tmp/pmaports-gitlab/device/*/device-oneplus-guacamole 2>/dev/null || echo "no guac device pkg"
ls -d /tmp/pmaports-gitlab/device/*/linux-postmarketos-qcom-sm8150 2>/dev/null || echo "no sm8150 kernel pkg"
ls -d /tmp/pmaports-gitlab/device/*/linux-oneplus-guacamole 2>/dev/null || echo "no linux-oneplus-guacamole"

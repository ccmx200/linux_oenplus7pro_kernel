#!/bin/bash
set -u
P=/tmp/pmaports-gitlab/device/testing/linux-postmarketos-qcom-sm8150
echo "=== 包目录"
ls -la "$P"
echo
echo "=== APKBUILD 关键行"
grep -n -E '^(pkgver|_commit|_tag|_config|source=)' "$P/APKBUILD"
sed -n '30,80p' "$P/APKBUILD"
echo
echo "=== device 包文件"
ls -la /tmp/pmaports-gitlab/device/testing/device-oneplus-guacamole/
echo
echo "=== deviceinfo"
cat /tmp/pmaports-gitlab/device/testing/device-oneplus-guacamole/deviceinfo

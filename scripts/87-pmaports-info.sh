#!/bin/bash
set -u
P=/tmp/pmaports-gitlab
echo "=== pmaports 版本/日期"
git -C "$P" log -1 --format='%h %ad %s' --date=short 2>&1 | head -2
echo
echo "=== 内核 APKBUILD"
sed -n '1,40p' "$P/device/testing/linux-postmarketos-qcom-sm8150/APKBUILD" 2>/dev/null
echo
echo "=== channels / binary repo 配置"
ls "$P"/*.cfg 2>/dev/null
grep -rn "pkgs.nura.eco\|mirrors\|http" "$P/pmaports.cfg" "$P/channels.cfg" 2>/dev/null | head -20
echo
echo "=== device APKBUILD depends"
sed -n '1,25p' "$P/device/testing/device-oneplus-guacamole/APKBUILD" 2>/dev/null
echo
echo "=== pkgs.nura.eco 页面（找 apk 链接）"
timeout 30 curl -sL "https://pkgs.nura.eco/package/main/postmarketos/aarch64/linux-postmarketos-qcom-sm8150" -o /tmp/pkgpage.html
grep -oE 'href="[^"]*\.apk"' /tmp/pkgpage.html | head -5
grep -oE 'https?://[^"]*apk[^"]*' /tmp/pkgpage.html | head -5

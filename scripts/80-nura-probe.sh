#!/bin/bash
set -u
echo "=== 1) Nura 包仓库里是否有 guacamole 的 device / kernel 预编译包"
for u in \
  "https://pkgs.nura.eco/package/main/postmarketos/aarch64/linux-postmarketos-qcom-sm8150" \
  "https://pkgs.nura.eco/package/main/device/aarch64/device-oneplus-guacamole" \
  "https://pkgs.nura.eco/package/main/device/testing/aarch64/device-oneplus-guacamole" \
  "https://pkgs.nura.eco/package/main/postmarketos/aarch64/linux-postmarketos-qcom-sm8150/download" ; do
  code=$(curl -s -o /dev/null -w '%{http_code}' --max-time 20 "$u")
  echo "$code  $u"
done

echo
echo "=== 2) 包索引里搜 guacamole / sm8150"
for idx in "https://pkgs.nura.eco/main/aarch64/APKINDEX.tar.gz" "https://pkgs.nura.eco/postmarketos/main/aarch64/APKINDEX.tar.gz"; do
  code=$(curl -s -o /tmp/idx.tgz -w '%{http_code}' --max-time 60 "$idx")
  echo "--- $idx -> $code"
  if [ "$code" = 200 ]; then
    tar -tzf /tmp/idx.tgz >/dev/null 2>&1 && { tar -xzf /tmp/idx.tgz -C /tmp APKINDEX 2>/dev/null; grep -E '^P:(linux-postmarketos-qcom-sm8150|device-oneplus-guacamole|linux-oneplus-guacamole)' -A3 /tmp/APKINDEX | head -20; }
  fi
done

echo
echo "=== 3) python / pip / git"
python3 --version; python3 -m pip --version 2>&1 | head -2; git --version
echo
echo "=== 4) gitlab.nura.eco 可达性"
curl -s -o /dev/null -w 'gitlab %{http_code}\n' --max-time 20 "https://gitlab.nura.eco/nura/pmaports"
curl -s -o /dev/null -w 'pmbootstrap %{http_code}\n' --max-time 20 "https://gitlab.nura.eco/nura/pmbootstrap"

#!/bin/bash
# 检查 ubuntu noble arm64 里这些包到底叫什么
set -u
M=https://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports
TMP=$(mktemp -d)
for comp in main universe; do
  for f in Packages.xz Packages.gz; do
    url="$M/dists/noble/$comp/binary-arm64/$f"
    if curl -fsSL --max-time 120 -o "$TMP/$comp.$f" "$url"; then
        if [ "$f" = Packages.xz ]; then xz -dc "$TMP/$comp.$f" > "$TMP/$comp.txt"; else zcat "$TMP/$comp.$f" > "$TMP/$comp.txt"; fi
        echo "got $comp ($(wc -l < "$TMP/$comp.txt") lines)"
        break
    fi
  done
done
for p in systemd systemd-resolved systemd-networkd systemd-timesyncd openssh-server; do
    if grep -qx "Package: $p" "$TMP"/main.txt "$TMP"/universe.txt 2>/dev/null; then
        echo "FOUND   $p"
    else
        echo "MISSING $p"
    fi
done
echo "--- 相近名字"
grep -h "^Package: systemd" "$TMP"/main.txt "$TMP"/universe.txt 2>/dev/null | sort -u | head -20
rm -rf "$TMP"

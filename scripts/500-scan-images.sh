#!/bin/bash
set -u
D="/mnt/d/Flyme9_ArtChen_9008FlashPackage/Flyme9_ArtChen_9008FlashPackage/images"
echo "=== 镜像列表"
ls -lh "$D"/*.img | awk '{print $5, $9}' | head -20
echo
echo "=== 在所有 img 里搜 bdwlan / board-2 / qca_cld 字符串"
for f in "$D"/*.img; do
  hit=$(grep -aob -m1 -E 'bdwlan|board-2\.bin|qca_cld|WCN3990' "$f" 2>/dev/null | head -1)
  [ -n "$hit" ] && echo "$(basename "$f"): $hit"
done

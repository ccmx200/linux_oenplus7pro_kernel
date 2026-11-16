#!/bin/bash
set -uo pipefail
P=/root/hotdog/aports/device/testing/linux-oneplus-hotdog-mainline616/0012-drm-msm-enable-native-hotdog-dsc-panel.patch
OUT=/root/panel-driver.patch
python3 - "$P" "$OUT" <<'PY'
import sys
src, out = sys.argv[1], sys.argv[2]
lines = open(src).read().splitlines(keepends=True)
chunks, cur, keep = [], [], False
for ln in lines:
    if ln.startswith('diff --git '):
        if cur and keep: chunks.append(''.join(cur))
        cur = [ln]; keep = 'sm8150-oneplus-hotdog.dts' not in ln
    else:
        cur.append(ln)
if cur and keep: chunks.append(''.join(cur))
open(out,'w').write(''.join(chunks))
for c in chunks: print(" ", c.splitlines()[0][:95])
PY
cd /root/kbuild/linux
echo "=== 应用（非 DTS 部分）"
git apply --3way /root/panel-driver.patch 2>&1 | head -8 || true
echo "=== 检查文件"
ls -l drivers/gpu/drm/panel/panel-samsung-oneplus-dsc.c 2>/dev/null || echo "驱动文件未生成"
grep -n "oneplus-dsc" drivers/gpu/drm/panel/Kconfig drivers/gpu/drm/panel/Makefile 2>/dev/null | head -4
grep -n "dsc_slice_per_pkt" drivers/gpu/drm/msm/dsi/dsi_host.c | head -3

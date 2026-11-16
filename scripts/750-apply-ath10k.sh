#!/bin/bash
set -uo pipefail
P=/root/hotdog/aports/device/testing/linux-oneplus-hotdog-mainline616/0156-hotdog-integrate-validated-runtime-fixes.patch
OUT=/root/ath10k-fixes.patch
python3 - "$P" "$OUT" <<'PY'
import sys
src, out = sys.argv[1], sys.argv[2]
lines = open(src).read().splitlines(keepends=True)
chunks, cur, keep = [], [], False
for ln in lines:
    if ln.startswith('diff --git '):
        if cur and keep: chunks.append(''.join(cur))
        cur = [ln]; keep = 'drivers/net/wireless/ath/ath10k' in ln
    else:
        cur.append(ln)
if cur and keep: chunks.append(''.join(cur))
open(out,'w').write(''.join(chunks))
print("extracted bytes:", sum(len(c) for c in chunks), "chunks:", len(chunks))
for c in chunks:
    print("  ", c.splitlines()[0][:90])
PY
echo "=== 应用到内核树"
cd /root/kbuild/linux
git apply --3way /root/ath10k-fixes.patch 2>&1 | head -10 || git apply /root/ath10k-fixes.patch 2>&1 | head -10
echo "=== 结果检查"
grep -n "reclaim_msa\|wlan left enabled" drivers/net/wireless/ath/ath10k/qmi.c | head -5

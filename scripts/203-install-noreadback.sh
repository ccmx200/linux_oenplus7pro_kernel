#!/bin/bash
set -euo pipefail
IMG=/root/imgbuild/rootfs.img
python3 - <<'PY'
import re
p="/tmp/r.dts"
s=open(p).read()
s=re.sub(r"\n\s*;\s*\n", "\n", s)
open(p,"w").write(s)
print("stray semicolons cleaned")
PY
dtc -I dts -O dtb /tmp/r.dts -o /tmp/r.dtb 2>/tmp/dtc.err || true
head -3 /tmp/dtc.err
echo "qcom,no-readback: $(dtc -I dtb -O dts /tmp/r.dtb 2>/dev/null | grep -c 'qcom,no-readback')"
echo "pm8009 present: $(dtc -I dtb -O dts /tmp/r.dtb 2>/dev/null | grep -c 'pm8009-rpmh-regulators' || true)"

L=$(losetup -j "$IMG" | cut -d: -f1 | head -1)
[ -z "${L:-}" ] && { L=$(losetup -fP --sector-size 4096 "$IMG" --show); sleep 1; }
mkdir -p /mnt/p1
mountpoint -q /mnt/p1 || mount "${L}p1" /mnt/p1
cp -f /tmp/r.dtb /mnt/p1/dtbs/qcom/sm8150-oneplus-guacamole.dtb
ls -lh /mnt/p1/dtbs/qcom/sm8150-oneplus-guacamole.dtb
sync
umount /mnt/p1
losetup -d "$L" 2>/dev/null || true
echo DTB_INSTALLED


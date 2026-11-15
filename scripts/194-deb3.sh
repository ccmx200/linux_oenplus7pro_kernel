#!/bin/bash
set -euo pipefail
cd /root/kbuild/linux
python3 - <<'PY'
p="scripts/Makefile.package"
s=open(p).read()
old="+$(strip dpkg-buildpackage \\\n\t--build="
new="+$(strip dpkg-buildpackage -d \\\n\t--build="
assert old in s, "pattern missing"
open(p,'w').write(s.replace(old,new,1))
print("patched -d")
PY
make -j"$(nproc)" ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- bindeb-pkg 2>&1 | tail -8
ls -lh /root/kbuild/*.deb 2>/dev/null | head

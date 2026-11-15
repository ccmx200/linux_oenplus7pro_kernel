#!/bin/bash
set -euo pipefail
cd /root/kbuild/linux
python3 - <<'PY'
p="scripts/Makefile.package"
s=open(p).read()
if "-d --build" not in s:
    s=s.replace("dpkg-buildpackage $(DPKG_FLAGS)", "dpkg-buildpackage -d $(DPKG_FLAGS)")
    open(p,'w').write(s)
print([l for l in s.splitlines() if 'dpkg-buildpackage' in l][:4])
PY
make -j"$(nproc)" ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- bindeb-pkg 2>&1 | tail -8
ls -lh /root/kbuild/*.deb 2>/dev/null | head

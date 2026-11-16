#!/bin/bash
set -u
B=/root/.local/var/pmbootstrap/chroot_rootfs_oneplus-guacamole/boot
ls -lh "$B"
echo "=== 内核版本字符串"
strings "$B/vmlinuz" 2>/dev/null | grep -m3 "Linux version" || \
  (command -v python3 >/dev/null && python3 - "$B/vmlinuz" <<'PY'
import sys,re
d=open(sys.argv[1],'rb').read()
m=re.findall(rb'Linux version [^\x00]{10,120}', d)
for x in m[:3]: print(x.decode('latin1'))
PY
)
echo "=== 尝试提取 config"
if [ -x /root/kbuild/linux/scripts/extract-ikconfig ]; then
  sh /root/kbuild/linux/scripts/extract-ikconfig "$B/vmlinuz" 2>/dev/null | grep -E "CONFIG_ATH10K|CONFIG_QCOM_PWRSEQ|CONFIG_QRTR|CONFIG_QCOM_QMI" | head -20
fi
echo "=== dtb 大小与 WiFi 状态"
ls -lh "$B/dtbs/qcom" 2>/dev/null | head

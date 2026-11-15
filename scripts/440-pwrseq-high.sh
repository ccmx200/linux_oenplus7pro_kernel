#!/bin/bash
# 补丁：pwrseq wlan-enable 初值改为 HIGH（probe 时立即给芯片上电）
set -uo pipefail
K=/root/kbuild/linux
F=$K/drivers/power/sequencing/pwrseq-qcom-wcn.c
cp -f "$F" /root/pwrseq-qcom-wcn.c.orig

python3 - "$F" <<'PY'
import sys
p=sys.argv[1]; s=open(p).read()
old='ctx->wlan_gpio = devm_gpiod_get_optional(dev, "wlan-enable",\n\t\t\t\t\t\t GPIOD_OUT_LOW);'
new='ctx->wlan_gpio = devm_gpiod_get_optional(dev, "wlan-enable",\n\t\t\t\t\t\t GPIOD_OUT_HIGH);'
assert old in s, "pattern not found"
open(p,"w").write(s.replace(old,new,1))
print("patched GPIOD_OUT_LOW -> HIGH for wlan-enable")
PY
diff -u /root/pwrseq-qcom-wcn.c.orig "$F" > /root/pwrseq-swctrl.patch || true
echo "--- patch"
head -12 /root/pwrseq-swctrl.patch

cd "$K"
make -C . M=drivers/power/sequencing modules 2>&1 | tail -5
ls -lh drivers/power/sequencing/pwrseq-qcom-wcn.ko

OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
KV=$(sshpass -p 1234 ssh $OPTS root@172.16.42.1 'uname -r' 2>/dev/null | tr -d '\r')
echo "device kernel: $KV"
DEST=/lib/modules/$KV/kernel/drivers/power/sequencing
sshpass -p 1234 ssh $OPTS root@172.16.42.1 "mkdir -p $DEST" 2>&1 | grep -v Warning
sshpass -p 1234 scp $OPTS drivers/power/sequencing/pwrseq-qcom-wcn.ko root@172.16.42.1:$DEST/ 2>&1 | grep -v Warning
sshpass -p 1234 ssh $OPTS root@172.16.42.1 'depmod -a; sync; reboot' 2>&1 | grep -v Warning
echo rebooting

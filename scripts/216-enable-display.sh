#!/bin/bash
# 在设备上打开 display-subsystem / dsi 节点（改 /boot 里的 DTB 并重启）
set -u
SSH="sshpass -p 1234 ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no root@172.16.42.1"

echo "=== ESP 挂载点"
$SSH 'mount | grep -E "vfat|/boot" | head -5; ls /boot/dtbs/qcom/sm8150-oneplus-guacamole.dtb' 2>&1 | grep -v Warning

echo "=== 取回 DTB"
sshpass -p 1234 scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
  root@172.16.42.1:/boot/dtbs/qcom/sm8150-oneplus-guacamole.dtb /root/dev-guac.dtb 2>&1 | grep -v Warning
ls -lh /root/dev-guac.dtb

echo "=== 打开显示节点"
dtc -I dtb -O dts /root/dev-guac.dtb -o /tmp/d.dts 2>/dev/null
python3 - <<'PY'
import re
p="/tmp/d.dts"; s=open(p).read()
targets = ["display-subsystem@ae00000", "dsi@ae94000", "dsi@ae96000", "phy@ae94400", "phy@ae96400"]
out=[]; cur=None; depth=0; changed=0
lines=s.split("\n")
stack=[]
for ln in lines:
    m=re.match(r"^(\s*)([A-Za-z0-9,._@+-]+) \{", ln)
    if m:
        stack.append(m.group(2))
    if re.match(r"^\s*status = ", ln) and any(t in stack for t in targets):
        ln = re.sub(r'status = "disabled"', 'status = "okay"', ln)
        changed += 1
    out.append(ln)
    if ln.strip() == "}" and stack:
        stack.pop()
s2="\n".join(out)
# 若 display 节点本身没有 status 属性，补一个
print("status changed:", changed)
open(p,"w").write(s2)
PY
grep -n -A2 'display-subsystem@ae00000 {' /tmp/d.dts | head -6
dtc -I dts -O dtb /tmp/d.dts -o /root/dev-guac-patched.dtb 2>/dev/null && ls -lh /root/dev-guac-patched.dtb

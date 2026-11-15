#!/bin/bash
# 给主线 sm8150.dtsi 的所有 glink edge 补 IPCRTR 通道，重编 DTB 并部署
set -uo pipefail
K=/root/kbuild/linux
D=$K/arch/arm64/boot/dts/qcom
F=$D/sm8150.dtsi
cp -f "$F" /root/sm8150.dtsi.bak

python3 - "$F" <<'PY'
import sys, re
p=sys.argv[1]; s=open(p).read()
def repl(m):
    inner = m.group(1)
    if "IPCRTR" in inner:
        return m.group(0)
    return f'qcom,glink-channels = "IPCRTR", {inner};'
s2 = re.sub(r'qcom,glink-channels = (".*?");', repl, s)
open(p,"w").write(s2)
print("channels patched:", s2.count("IPCRTR"))
PY

cd "$K"
rm -f "$D/sm8150-oneplus-guacamole.dtb"
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- qcom/sm8150-oneplus-guacamole.dtb 2>&1 | tail -6
ls -lh "$D/sm8150-oneplus-guacamole.dtb" 2>/dev/null || { cp -f /root/sm8150.dtsi.bak "$F"; echo RESTORED; exit 1; }

cp -f "$D/sm8150-oneplus-guacamole.dtb" /root/wz.dtb
dtc -I dtb -O dts /root/wz.dtb -o /tmp/wz.dts 2>/dev/null
python3 - <<'PY'
import re
p="/tmp/wz.dts"; s=open(p).read()
s=re.sub(r"\n\tmemory@[0-9a-f]+ \{.*?\n\t\};\n","\n",s,flags=re.S)
mem="""
	memory@80000000 { device_type = "memory"; reg = <0x00 0x80000000 0x00 0x3cc00000>; };
	memory@c0000000 { device_type = "memory"; reg = <0x00 0xc0000000 0x00 0x80000000>; };
	memory@100000000 { device_type = "memory"; reg = <0x01 0x00000000 0x00 0xc0000000>; };
"""
t=s.rstrip(); assert t.endswith("};")
i=t.rfind("\n};"); t=t[:i]+mem+t[i:]+"\n"; s=t
def fix(s,h):
    a=s.find(h)
    if a<0: return s,0
    j=s.find("{",a); d=0; k=j
    while k<len(s):
        if s[k]=="{": d+=1
        elif s[k]=="}":
            d-=1
            if d==0: break
        k+=1
    out=[];c=0
    for ln in s[a:k+1].split("\n"):
        out.append(ln)
        if re.match(r"^\t\t\t\t[a-z0-9-]+ \{$", ln):
            out.append("\t\t\t\t\tqcom,no-readback;"); c+=1
    return s[:a]+"\n".join(out)+s[k+1:], c
tot=0
for h in ("pm8150-rpmh-regulators {","pm8150l-rpmh-regulators {"): s,c=fix(s,h); tot+=c
a=s.find("pm8009-rpmh-regulators {")
if a>=0:
    j=s.find("{",a); d=0; k=j
    while k<len(s):
        if s[k]=="{": d+=1
        elif s[k]=="}":
            d-=1
            if d==0: break
        k+=1
    st=s.rfind("\n",0,a); s=s[:st]+s[k+1:]
s=re.sub(r"\n\s*;\s*\n","\n",s)
print("no-readback:",tot)
open(p,"w").write(s)
PY
dtc -I dts -O dtb /tmp/wz.dts -o /root/wz-patched.dtb 2>/dev/null
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
sshpass -p 1234 scp $OPTS /root/wz-patched.dtb root@172.16.42.1:/boot/dtbs/qcom/sm8150-oneplus-guacamole.dtb 2>&1 | grep -v Warning
sshpass -p 1234 ssh $OPTS root@172.16.42.1 'sync; reboot' 2>&1 | grep -v Warning
echo "rebooted with IPCRTR"

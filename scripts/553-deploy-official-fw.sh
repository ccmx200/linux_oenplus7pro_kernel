#!/bin/bash
set -uo pipefail
K=/root/kbuild/linux
D=$K/arch/arm64/boot/dts/qcom
C=/mnt/c/Users/cuicanmx/Documents/deepseek-harness/default-workspace/oneplus7pro/dts

python3 - "$C/sm8150-oneplus-guacamole.dts" <<'PY'
import sys, re
p=sys.argv[1]; s=open(p).read()
s = re.sub(r"\n\tfirmware-name = \"qcom/sm8150/oneplus7/bdwlan\.bin\";", "", s)
open(p,"w").write(s)
print("firmware-name removed:", "firmware-name" not in s)
PY
cp -f "$C/sm8150-oneplus-guacamole.dts" "$D/"
cd "$K"
rm -f "$D/sm8150-oneplus-guacamole.dtb"
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- qcom/sm8150-oneplus-guacamole.dtb 2>&1 | tail -2
cp -f "$D/sm8150-oneplus-guacamole.dtb" /root/wn.dtb
dtc -I dtb -O dts /root/wn.dtb -o /tmp/wn.dts 2>/dev/null
python3 - <<'PY'
import re
p="/tmp/wn.dts"; s=open(p).read()
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
open(p,"w").write(s)
PY
dtc -I dts -O dtb /tmp/wn.dts -o /root/wn-patched.dtb 2>/dev/null

OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
echo "=== 推固件"
sshpass -p 1234 ssh $OPTS root@172.16.42.1 'mkdir -p /lib/firmware/ath10k/WCN3990/hw1.0' 2>&1 | grep -v Warning
sshpass -p 1234 scp $OPTS /root/ath10kfw/wlanmdsp.mbn /root/ath10kfw/board-2.bin /root/ath10kfw/firmware-5.bin root@172.16.42.1:/lib/firmware/ath10k/WCN3990/hw1.0/ 2>&1 | grep -v Warning
sshpass -p 1234 scp $OPTS /root/wn-patched.dtb root@172.16.42.1:/boot/dtbs/qcom/sm8150-oneplus-guacamole.dtb 2>&1 | grep -v Warning
sshpass -p 1234 ssh $OPTS root@172.16.42.1 'ls -lh /lib/firmware/ath10k/WCN3990/hw1.0/; sync; reboot' 2>&1 | grep -v Warning
echo rebooting

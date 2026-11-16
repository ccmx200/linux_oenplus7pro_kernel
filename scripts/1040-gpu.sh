#!/bin/bash
set -uo pipefail
K=/root/kbuild/linux
D=$K/arch/arm64/boot/dts/qcom
C=/mnt/c/Users/cuicanmx/Documents/deepseek-harness/default-workspace/oneplus7pro/dts
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"

echo "=== 1. 部署 GPU 固件"
sshpass -p 1234 ssh $OPTS root@172.16.42.1 'mkdir -p /lib/firmware/qcom/sm8150/oneplus7' 2>&1 | grep -v Warning
sshpass -p 1234 scp $OPTS /root/hotdog-fw/a630_sqe.fw /root/hotdog-fw/a640_gmu.bin root@172.16.42.1:/lib/firmware/qcom/ 2>&1 | grep -v Warning
sshpass -p 1234 scp $OPTS /root/hotdog-fw/a640_zap.mbn root@172.16.42.1:/lib/firmware/qcom/sm8150/oneplus7/ 2>&1 | grep -v Warning

echo "=== 2. DTS 启用 GPU"
python3 - "$C/sm8150-oneplus-guacamole.dts" <<'PY'
import sys
p=sys.argv[1]; s=open(p).read()
if "&gmu {" in s:
    print("already")
else:
    s = s.rstrip() + """

/* Adreno 640 GPU + GMU */
&gmu {
	status = "okay";
};

&gpu {
	status = "okay";

	zap-shader {
		firmware-name = "qcom/sm8150/oneplus7/a640_zap.mbn";
	};
};
"""
    open(p,"w").write(s)
    print("gpu/gmu enabled")
PY
grep -n -A8 '&gpu {' "$C/sm8150-oneplus-guacamole.dts" | head -12

cp -f "$C/sm8150-oneplus-guacamole.dts" "$D/"
cd "$K"
rm -f "$D/sm8150-oneplus-guacamole.dtb"
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- qcom/sm8150-oneplus-guacamole.dtb 2>&1 | tail -2
cp -f "$D/sm8150-oneplus-guacamole.dtb" /root/gpu.dtb
dtc -I dtb -O dts /root/gpu.dtb -o /tmp/gpu.dts 2>/dev/null
python3 - <<'PY'
import re
p="/tmp/gpu.dts"; s=open(p).read()
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
dtc -I dts -O dtb /tmp/gpu.dts -o /root/gpu-final.dtb 2>/dev/null
cp -f /root/gpu-final.dtb /mnt/c/Users/cuicanmx/Documents/deepseek-harness/default-workspace/oneplus7pro/nura-out/sm8150-guac-gpu.dtb
sshpass -p 1234 scp $OPTS /root/gpu-final.dtb root@172.16.42.1:/boot/dtbs/qcom/sm8150-oneplus-guacamole.dtb 2>&1 | grep -v Warning
sshpass -p 1234 ssh $OPTS root@172.16.42.1 'ls -lh /lib/firmware/qcom/a630_sqe.fw /lib/firmware/qcom/a640_gmu.bin /lib/firmware/qcom/sm8150/oneplus7/a640_zap.mbn; sync; reboot' 2>&1 | grep -v Warning
echo rebooted

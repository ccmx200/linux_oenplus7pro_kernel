#!/bin/bash
set -uo pipefail
K=/root/kbuild/linux
D=$K/arch/arm64/boot/dts/qcom
C=/mnt/c/Users/cuicanmx/Documents/deepseek-harness/default-workspace/oneplus7pro/dts

echo "=== 现有 &wifi 覆盖"
grep -n -A8 '&wifi' "$C/sm8150-oneplus-common.dtsi" | head -15

python3 - "$C/sm8150-oneplus-guacamole.dts" <<'PY'
import sys
p=sys.argv[1]; s=open(p).read()
if "vdd-cx-mx-supply" in s:
    print("already patched"); raise SystemExit
s += """
/* ---- WCN3998 供电（按 vendor icnss 映射）：真实 regulator，不是 dummy ---- */
&wifi {
	vdd-cx-mx-supply   = <&vreg_l1a_0p75>;   /* pm8150_l1  */
	vdd-1.8-xo-supply  = <&vreg_l7a_1p8>;    /* pm8150_l7  */
	vdd-1.3-rfa-supply = <&vreg_l2c_1p3>;    /* pm8150l_l2 */
	vdd-3.3-ch0-supply = <&vreg_l11c_3p3>;   /* pm8150l_l11 */
	qcom,msa-fixed-perm;
};
"""
open(p,"w").write(s)
print("wifi supplies added")
PY

cp -f "$C/sm8150-oneplus-guacamole.dts" "$D/"
cd "$K"
rm -f "$D/sm8150-oneplus-guacamole.dtb"
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- qcom/sm8150-oneplus-guacamole.dtb 2>&1 | tail -6
ls -lh "$D/sm8150-oneplus-guacamole.dtb" 2>/dev/null || exit 1

# 后处理
cp -f "$D/sm8150-oneplus-guacamole.dtb" /root/wifi.dtb
dtc -I dtb -O dts /root/wifi.dtb -o /tmp/w.dts 2>/dev/null
python3 - <<'PY'
import re
p="/tmp/w.dts"; s=open(p).read()
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
dtc -I dts -O dtb /tmp/w.dts -o /root/wifi-patched.dtb 2>/dev/null
ls -lh /root/wifi-patched.dtb

OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
sshpass -p 1234 scp $OPTS /root/wifi-patched.dtb root@172.16.42.1:/boot/dtbs/qcom/sm8150-oneplus-guacamole.dtb 2>&1 | grep -v Warning
sshpass -p 1234 ssh $OPTS root@172.16.42.1 'sync; reboot' 2>&1 | grep -v Warning
echo rebooting

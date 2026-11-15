#!/bin/bash
set -uo pipefail
K=/root/kbuild/linux
D=$K/arch/arm64/boot/dts/qcom
C=/mnt/c/Users/cuicanmx/Documents/deepseek-harness/default-workspace/oneplus7pro/dts

python3 - "$C/sm8150-oneplus-guacamole.dts" <<'PY'
import sys, re
p=sys.argv[1]; s=open(p).read()
if "wlan_en_default" in s:
    print("already"); raise SystemExit
# pwrseq 节点：改用 wlan_en_default pinctrl（output-high，probe 即生效）
s = s.replace("\t\tpinctrl-0 = <&sw_ctrl_default>;", "\t\tpinctrl-0 = <&wlan_en_default>;")
s = s.replace('\t\twlan-enable-gpios = <&tlmm 169 GPIO_ACTIVE_HIGH>;',
              '\t\twlan-enable-gpios = <&tlmm 169 GPIO_ACTIVE_HIGH>;')
# 去掉旧 sw_ctrl_default（pm8150 gpio3）
s = re.sub(r"\n&pm8150_gpios \{\n\tsw_ctrl_default: sw-ctrl-default-state \{.*?\n\t\};\n\};\n", "\n", s, flags=re.S)
s += """
&tlmm {
	wlan_en_default: wlan-en-default-state {
		pins = "gpio169";
		function = "gpio";
		drive-strength = <2>;
		bias-disable;
		output-high;
	};
};
"""
open(p,"w").write(s)
print("wlan_en_default(output-high) added for tlmm 169")
PY
grep -n -A4 'wlan_en_default' "$C/sm8150-oneplus-guacamole.dts" | head -10

cp -f "$C/sm8150-oneplus-guacamole.dts" "$D/"
cd "$K"
rm -f "$D/sm8150-oneplus-guacamole.dtb"
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- qcom/sm8150-oneplus-guacamole.dtb 2>&1 | tail -5
ls -lh "$D/sm8150-oneplus-guacamole.dtb" 2>/dev/null || exit 1
cp -f "$D/sm8150-oneplus-guacamole.dtb" /root/w9.dtb
dtc -I dtb -O dts /root/w9.dtb -o /tmp/w9.dts 2>/dev/null
python3 - <<'PY'
import re
p="/tmp/w9.dts"; s=open(p).read()
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
dtc -I dts -O dtb /tmp/w9.dts -o /root/w9-patched.dtb 2>/dev/null
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
sshpass -p 1234 scp $OPTS /root/w9-patched.dtb root@172.16.42.1:/boot/dtbs/qcom/sm8150-oneplus-guacamole.dtb 2>&1 | grep -v Warning
sshpass -p 1234 ssh $OPTS root@172.16.42.1 'sync; reboot' 2>&1 | grep -v Warning
echo rebooting

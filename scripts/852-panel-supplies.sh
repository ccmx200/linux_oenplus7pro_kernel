#!/bin/bash
set -uo pipefail
K=/root/kbuild/linux
D=$K/arch/arm64/boot/dts/qcom
C=/mnt/c/Users/cuicanmx/Documents/deepseek-harness/default-workspace/oneplus7pro/dts

python3 - "$C/sm8150-oneplus-guacamole.dts" <<'PY'
import sys, re
p=sys.argv[1]; s=open(p).read()
# dsi0: 加 vdda-supply
s = s.replace("""&mdss_dsi0 {
	status = "okay";""",
"""&mdss_dsi0 {
	status = "okay";
	vdda-supply = <&vreg_l3c_1p2>;""")
# phy: 加 vdds-supply
s = s.replace("""&mdss_dsi0_phy {
	status = "okay";
};""",
"""&mdss_dsi0_phy {
	status = "okay";
	vdds-supply = <&vreg_l5a_0p875>;
};""")
open(p,"w").write(s)
print("dsi supplies added")
PY
grep -n -A4 '&mdss_dsi0 {\|&mdss_dsi0_phy {' "$C/sm8150-oneplus-guacamole.dts" | head -16

cp -f "$C/sm8150-oneplus-guacamole.dts" "$D/"
cd "$K"
rm -f "$D/sm8150-oneplus-guacamole.dtb"
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- qcom/sm8150-oneplus-guacamole.dtb 2>&1 | tail -2
cp -f "$D/sm8150-oneplus-guacamole.dtb" /root/panel2.dtb
dtc -I dtb -O dts /root/panel2.dtb -o /tmp/panel2.dts 2>/dev/null
python3 - <<'PY'
import re
p="/tmp/panel2.dts"; s=open(p).read()
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
dtc -I dts -O dtb /tmp/panel2.dts -o /root/panel2-final.dtb 2>/dev/null
cp -f /root/panel2-final.dtb /mnt/c/Users/cuicanmx/Documents/deepseek-harness/default-workspace/oneplus7pro/nura-out/sm8150-guac-panel-dsi2.dtb
ls -lh /root/panel2-final.dtb

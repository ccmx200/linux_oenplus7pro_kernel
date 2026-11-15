#!/bin/bash
set -uo pipefail
K=/root/kbuild/linux
D=$K/arch/arm64/boot/dts/qcom
C=/mnt/c/Users/cuicanmx/Documents/deepseek-harness/default-workspace/oneplus7pro/dts

python3 - "$C/sm8150-oneplus-guacamole.dts" <<'PY'
import sys, re
p=sys.argv[1]; s=open(p).read()
# 删掉旧 pwrseq 与旧 wifi supply 覆盖
s = re.sub(r"\n/\ \{\n\twcn3998_pmu: pwrseq \{.*?\n\};\n", "\n", s, flags=re.S)
s = re.sub(r"\n&wifi \{\n\tvdd-cx-mx-supply.*?\n\};\n", "\n", s, flags=re.S)
s = re.sub(r"\n&wifi \{\n\tvdd-0\.8-cx-mx-supply.*?\n\};\n", "\n", s, flags=re.S)

block = """
/* ---- WCN3998 PMU（按 sm8150-hdk 的写法：pwrseq + 内部 fixed LDO） ---- */
/ {
	wcn3998_pmu: pwrseq {
		compatible = "qcom,wcn3998-pmu";

		pinctrl-0 = <&sw_ctrl_default>;
		pinctrl-names = "default";

		vddio-supply  = <&vreg_l1c_1p8>;
		vddxo-supply  = <&vreg_l7a_1p8>;
		vddrf-supply  = <&vreg_l2c_1p3>;
		vddch0-supply = <&vreg_l11c_3p3>;
		vddch1-supply = <&vreg_l10c_3p3>;

		swctrl-gpios = <&pm8150_gpios 3 GPIO_ACTIVE_HIGH>;

		regulators {
			vreg_pmu_io: ldo0 {
				regulator-name = "vreg_pmu_io";
			};

			vreg_pmu_xo: ldo1 {
				regulator-name = "vreg_pmu_xo";
			};

			vreg_pmu_rf: ldo2 {
				regulator-name = "vreg_pmu_rf";
			};

			vreg_pmu_ch0: ldo3 {
				regulator-name = "vreg_pmu_ch0";
			};

			vreg_pmu_ch1: ldo4 {
				regulator-name = "vreg_pmu_ch1";
			};
		};
	};
};

&wifi {
	vdd-0.8-cx-mx-supply = <&vreg_l1a_0p75>;
	vdd-1.8-xo-supply    = <&vreg_pmu_xo>;
	vdd-1.3-rfa-supply   = <&vreg_pmu_rf>;
	vdd-3.3-ch0-supply   = <&vreg_pmu_ch0>;
	vdd-3.3-ch1-supply   = <&vreg_pmu_ch1>;

	qcom,calibration-variant = "oneplus_sm8150";
	qcom,snoc-host-cap-8bit-quirk;

	pwrseq = <&wcn3998_pmu>;
	pwrseq-names = "wlan";

	status = "okay";
};
"""
s += block
open(p,"w").write(s)
print("pwrseq with regulators rebuilt")
PY

cp -f "$C/sm8150-oneplus-guacamole.dts" "$D/"
cd "$K"
rm -f "$D/sm8150-oneplus-guacamole.dtb"
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- qcom/sm8150-oneplus-guacamole.dtb 2>&1 | tail -8
ls -lh "$D/sm8150-oneplus-guacamole.dtb" 2>/dev/null || exit 1
cp -f "$D/sm8150-oneplus-guacamole.dtb" /root/w6.dtb
dtc -I dtb -O dts /root/w6.dtb -o /tmp/w6.dts 2>/dev/null
python3 - <<'PY'
import re
p="/tmp/w6.dts"; s=open(p).read()
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
dtc -I dts -O dtb /tmp/w6.dts -o /root/w6-patched.dtb 2>/dev/null
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
sshpass -p 1234 scp $OPTS /root/w6-patched.dtb root@172.16.42.1:/boot/dtbs/qcom/sm8150-oneplus-guacamole.dtb 2>&1 | grep -v Warning
sshpass -p 1234 ssh $OPTS root@172.16.42.1 'sync; reboot' 2>&1 | grep -v Warning
echo rebooting

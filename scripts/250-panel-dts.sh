#!/bin/bash
# 给 guac DTS 加 LAB/IBB + panel 节点，编译 DTB，后处理，推到设备测试
set -uo pipefail
K=/root/kbuild/linux
D=$K/arch/arm64/boot/dts/qcom
C=/mnt/c/Users/cuicanmx/Documents/deepseek-harness/default-workspace/oneplus7pro/dts

echo "=== PM8150L 的 USID / 节点"
grep -n 'pm8150l:' "$D/pm8150l.dtsi" | head -2
USID=$(grep -oP 'pm8150l: pmic@\K[0-9a-f]+' "$D/pm8150l.dtsi" | head -1)
echo "USID=$USID"

echo "=== dsi0 / mdss 标签"
grep -n 'dsi0:\|mdss:' "$D/sm8150.dtsi" | head -4

echo "=== 在 guacamole.dts 里追加 panel + labibb + 打开显示"
python3 - "$C/sm8150-oneplus-guacamole.dts" "$USID" <<'PY'
import sys
p, usid = sys.argv[1], sys.argv[2]
s = open(p).read()
if "ams639rq08" in s:
    print("already patched"); sys.exit(0)

usid = usid or "3"
extra = f"""
/* ---- OnePlus 7 Pro display (LAB/IBB + panel) ---- */
&pm8150l {{
	labibb {{
		compatible = "qcom,pmi8998-lab-ibb";

		ibb: ibb {{
			interrupts = <{usid} 0xdc 0x2 IRQ_TYPE_EDGE_RISING>,
				     <{usid} 0xdc 0x0 IRQ_TYPE_LEVEL_HIGH>;
			interrupt-names = "sc-err", "ocp";
		}};

		lab: lab {{
			interrupts = <{usid} 0xde 0x1 IRQ_TYPE_EDGE_RISING>,
				     <{usid} 0xde 0x0 IRQ_TYPE_LEVEL_LOW>;
			interrupt-names = "sc-err", "ocp";
		}};
	}};
}};

&mdss {{
	status = "okay";
}};

&dsi0 {{
	status = "okay";
	vdda-supply = <&vdda_dsi_0_0p9>;
	vdda-phy-supply = <&vreg_l3c_1p2>;
	vdda-pll-supply = <&vreg_l3c_1p2>;

	panel@0 {{
		compatible = "samsung,ams639rq08";
		reg = <0>;
		vdd3p3-supply = <&vreg_l11c_3p3>;
		vddio-supply = <&vreg_l1c_1p8>;
		vsp-supply = <&lab>;
		vsn-supply = <&ibb>;
		reset-gpios = <&tlmm 6 GPIO_ACTIVE_LOW>;
	}};
}};
"""
s += extra
open(p, "w").write(s)
print("added panel + labibb")
PY

echo "=== 编译 DTB"
cd "$K"
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- qcom/sm8150-oneplus-guacamole.dtb 2>&1 | tail -12
DTB=$D/sm8150-oneplus-guacamole.dtb
ls -lh "$DTB" 2>/dev/null || { echo "DTB 编译失败"; exit 1; }

echo "=== 后处理：6GB memory + no-readback"
cp -f "$DTB" /root/new-guac.dtb
dtc -I dtb -O dts /root/new-guac.dtb -o /tmp/n.dts 2>/dev/null
python3 - <<'PY'
import re
p="/tmp/n.dts"; s=open(p).read()
# memory
s=re.sub(r"\n\tmemory@[0-9a-f]+ \{.*?\n\t\};\n", "\n", s, flags=re.S)
mem = """
	memory@80000000 {
		device_type = "memory";
		reg = <0x00 0x80000000 0x00 0x3cc00000>;
	};

	memory@c0000000 {
		device_type = "memory";
		reg = <0x00 0xc0000000 0x00 0x80000000>;
	};

	memory@100000000 {
		device_type = "memory";
		reg = <0x01 0x00000000 0x00 0xc0000000>;
	};
"""
t=s.rstrip(); assert t.endswith("};")
i=t.rfind("\n};"); t=t[:i]+mem+t[i:]+"\n"; s=t
# no-readback: 在每个 regulator 容器里给子节点加
def fix(s, header):
    a = s.find(header)
    if a < 0: return s, 0
    j = s.find("{", a); depth=0; k=j
    while k < len(s):
        if s[k]=="{": depth+=1
        elif s[k]=="}":
            depth-=1
            if depth==0: break
        k+=1
    blk=s[a:k+1].split("\n"); out=[]; cnt=0
    for ln in blk:
        out.append(ln)
        if re.match(r"^\t\t\t\t[a-z0-9-]+ \{$", ln):
            out.append("\t\t\t\t\tqcom,no-readback;"); cnt+=1
    return s[:a]+"\n".join(out)+s[k+1:], cnt
tot=0
for h in ("pm8150-rpmh-regulators {","pm8150l-rpmh-regulators {"):
    s,c=fix(s,h); tot+=c
# 删 pm8009
a=s.find("pm8009-rpmh-regulators {")
if a>=0:
    j=s.find("{",a); depth=0; k=j
    while k<len(s):
        if s[k]=="{": depth+=1
        elif s[k]=="}":
            depth-=1
            if depth==0: break
        k+=1
    st=s.rfind("\n",0,a); s=s[:st]+s[k+1:]
s=re.sub(r"\n\s*;\s*\n","\n",s)
print("no-readback:",tot)
open(p,"w").write(s)
PY
dtc -I dts -O dtb /tmp/n.dts -o /root/new-guac-patched.dtb 2>/dev/null
echo "qcom,no-readback: $(dtc -I dtb -O dts /root/new-guac-patched.dtb 2>/dev/null | grep -c 'qcom,no-readback')"
ls -lh /root/new-guac-patched.dtb

echo "=== 推到设备并重启"
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no"
sshpass -p 1234 scp $OPTS /root/new-guac-patched.dtb root@172.16.42.1:/boot/dtbs/qcom/sm8150-oneplus-guacamole.dtb 2>&1 | grep -v Warning
sshpass -p 1234 ssh $OPTS root@172.16.42.1 'sync; reboot' 2>&1 | grep -v Warning
echo "rebooted"

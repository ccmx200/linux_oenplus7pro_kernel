#!/bin/bash
# 用法: 412-try-pin.sh <tlmm|pm8150> <pin>
set -uo pipefail
CTRL="$1"; PINNUM="$2"
K=/root/kbuild/linux
D=$K/arch/arm64/boot/dts/qcom
C=/mnt/c/Users/cuicanmx/Documents/deepseek-harness/default-workspace/oneplus7pro/dts

python3 - "$C/sm8150-oneplus-guacamole.dts" "$CTRL" "$PINNUM" <<'PY'
import sys, re
p, ctrl, pin = sys.argv[1], sys.argv[2], sys.argv[3]
s = open(p).read()

# 1) 删除旧的 wlan_en_default 定义（含外层 node 包装）
key = "wlan_en_default: wlan-en-default-state {"
while True:
    i = s.find(key)
    if i < 0:
        break
    # 向前找到外层 node 起始 "&xxx {" 行
    start = s.rfind("&", 0, i)
    start = s.rfind("\n", 0, start) + 1
    # 花括号匹配到 key 的结束
    j = s.find("{", i); depth = 0; k = j
    while k < len(s):
        if s[k] == "{": depth += 1
        elif s[k] == "}":
            depth -= 1
            if depth == 0: break
        k += 1
    # 跳过 key 块后的 "};"（外层 node 结束）
    rest = s[k+1:]
    m = re.match(r"\s*\};\s*\n", rest)
    end = k + 1 + (m.end() if m else 0)
    s = s[:start] + s[end:]

# 2) 设置 wlan-enable-gpios
if ctrl == "pm8150":
    ph, func = "&pm8150_gpios", "normal"
else:
    ph, func = "&tlmm", "gpio"
s = re.sub(r"wlan-enable-gpios = <[^>]*>;",
           f"wlan-enable-gpios = <{ph} {pin} GPIO_ACTIVE_HIGH>;", s)

# 3) 追加新的 pinctrl（output-high，probe 时生效）
s += f"""
{ph} {{
	wlan_en_default: wlan-en-default-state {{
		pins = "gpio{pin}";
		function = "{func}";
		bias-disable;
		output-high;
	}};
}};
"""
open(p, "w").write(s)
print(f"pin set: {ph} {pin}")
PY

cp -f "$C/sm8150-oneplus-guacamole.dts" "$D/"
cd "$K"
rm -f "$D/sm8150-oneplus-guacamole.dtb"
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- qcom/sm8150-oneplus-guacamole.dtb 2>&1 | tail -3
ls -lh "$D/sm8150-oneplus-guacamole.dtb" 2>/dev/null || exit 1
cp -f "$D/sm8150-oneplus-guacamole.dtb" /root/wx.dtb
dtc -I dtb -O dts /root/wx.dtb -o /tmp/wx.dts 2>/dev/null
python3 - <<'PY'
import re
p="/tmp/wx.dts"; s=open(p).read()
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
dtc -I dts -O dtb /tmp/wx.dts -o /root/wx-patched.dtb 2>/dev/null
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
sshpass -p 1234 scp $OPTS /root/wx-patched.dtb root@172.16.42.1:/boot/dtbs/qcom/sm8150-oneplus-guacamole.dtb 2>&1 | grep -v Warning
sshpass -p 1234 ssh $OPTS root@172.16.42.1 'sync; reboot' 2>&1 | grep -v Warning
echo "rebooted: $CTRL $PINNUM"

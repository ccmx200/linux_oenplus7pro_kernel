#!/bin/bash
set -uo pipefail
K=/root/kbuild/linux
DTB=$K/arch/arm64/boot/dts/qcom/sm8150-oneplus-guacamole.dtb
cp -f "$DTB" /root/new-guac.dtb
dtc -I dtb -O dts /root/new-guac.dtb -o /tmp/n.dts 2>/dev/null
python3 - <<'PY'
import re
p="/tmp/n.dts"; s=open(p).read()
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
def fix(s, header):
    a=s.find(header)
    if a<0: return s,0
    j=s.find("{",a); d=0; k=j
    while k<len(s):
        if s[k]=="{": d+=1
        elif s[k]=="}":
            d-=1
            if d==0: break
        k+=1
    blk=s[a:k+1].split("\n"); out=[]; c=0
    for ln in blk:
        out.append(ln)
        if re.match(r"^\t\t\t\t[a-z0-9-]+ \{$", ln):
            out.append("\t\t\t\t\tqcom,no-readback;"); c+=1
    return s[:a]+"\n".join(out)+s[k+1:], c
tot=0
for h in ("pm8150-rpmh-regulators {","pm8150l-rpmh-regulators {"):
    s,c=fix(s,h); tot+=c
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
print("no-readback:",tot,"labibb:",s.count("lab-ibb"),"panel:",s.count("ams639rq08"))
open(p,"w").write(s)
PY
dtc -I dts -O dtb /tmp/n.dts -o /root/new-guac-patched.dtb 2>/dev/null
ls -lh /root/new-guac-patched.dtb
echo "drm/panel in dtb:"
dtc -I dtb -O dts /root/new-guac-patched.dtb 2>/dev/null | grep -c 'ams639rq08\|lab-ibb'

OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no"
sshpass -p 1234 scp $OPTS /root/new-guac-patched.dtb root@172.16.42.1:/boot/dtbs/qcom/sm8150-oneplus-guacamole.dtb 2>&1 | grep -v Warning
sshpass -p 1234 ssh $OPTS root@172.16.42.1 'sync; reboot' 2>&1 | grep -v Warning
echo rebooted

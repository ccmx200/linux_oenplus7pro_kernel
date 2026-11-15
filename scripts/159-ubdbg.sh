#!/bin/bash
# 加按钮调试打印并重编 U-Boot
set -euo pipefail
U=/root/uboot
python3 - "$U" <<'PY'
import sys
U=sys.argv[1]
p1=U+"/drivers/button/button-qcom-pmic.c"
s=open(p1).read()
old="""		uc_plat = dev_get_uclass_plat(dev);
		uc_plat->label = btn_data->label;"""
new="""		uc_plat = dev_get_uclass_plat(dev);
		uc_plat->label = btn_data->label;
		printf("BTNDBG bind: node=%s label=%s\\n", label, uc_plat->label);"""
assert old in s
open(p1,'w').write(s.replace(old,new,1))

p2=U+"/common/button_cmd.c"
s=open(p2).read()
old2="""	button_get_by_label(cmd->btn_name, &btn);
	if (!btn) {
		log_err("No button labelled '%s'\\n", cmd->btn_name);
		return 0;
	}"""
new2="""	button_get_by_label(cmd->btn_name, &btn);
	if (!btn) {
		printf("BTNDBG no button labelled '%s'\\n", cmd->btn_name);
		return 0;
	}
	printf("BTNDBG got button '%s'\\n", cmd->btn_name);"""
assert old2 in s
open(p2,'w').write(s.replace(old2,new2,1))
print("patched debug")
PY

cd "$U"
make O=.output CROSS_COMPILE=aarch64-linux-gnu- -j"$(nproc)" CONFIG_DEFAULT_DEVICE_TREE=qcom/sm8150-oneplus-guacamole 2>&1 | tail -3

O=$U/.output
OUT=/mnt/c/Users/cuicanmx/Documents/deepseek-harness/default-workspace/oneplus7pro/nura-out
cd "$O"
gzip -9 -c u-boot-nodtb.bin > u-boot-nodtb.bin.gz
cat u-boot-nodtb.bin.gz dts/upstream/src/arm64/qcom/sm8150-oneplus-guacamole.dtb > uboot-dtb
MKB=$(ls /root/op7p/work/mkbootimg/mkbootimg 2>/dev/null || command -v mkbootimg)
"$MKB" --base 0x0 --kernel_offset 0x00008000 --pagesize 4096 \
       --kernel uboot-dtb -o "$OUT/uboot-guacamole-dbg.img"
ls -lh "$OUT/uboot-guacamole-dbg.img"

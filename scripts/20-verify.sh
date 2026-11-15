#!/bin/bash
# 验证内核产物：config 关键项 + DTB 内容
set -u
K=/root/op7p/work/linux
DTB=$K/arch/arm64/boot/dts/qcom/sm8150-oneplus-guacamole.dtb
echo "=== kernel release"; cat "$K/include/config/kernel.release" 2>/dev/null
echo "=== Image.gz"; file "$K/arch/arm64/boot/Image.gz"; gzip -t "$K/arch/arm64/boot/Image.gz" && echo "gzip OK"
echo "=== key CONFIG"
for c in CONFIG_SCSI_UFS_QCOM CONFIG_DRM_SIMPLEDRM CONFIG_DRM_MSM CONFIG_DRM_FBDEV_EMULATION \
         CONFIG_FRAMEBUFFER_CONSOLE CONFIG_USB_CONFIGFS CONFIG_USB_CONFIGFS_NCM CONFIG_USB_CONFIGFS_RNDIS \
         CONFIG_USB_DWC3 CONFIG_USB_DWC3_GADGET CONFIG_EXT4_FS CONFIG_PINCTRL_SM8150 CONFIG_SM_GCC_8150 \
         CONFIG_SERIAL_MSM_GENI_CONSOLE CONFIG_PHY_QCOM_QMP_UFS CONFIG_PHY_QCOM_QUSB2; do
    line=$(grep -E "^${c}=" "$K/.config" 2>/dev/null)
    printf '%-34s %s\n' "$c" "${line:-NOT SET}"
done
echo "=== DTB decompile"
dtc -I dtb -O dts "$DTB" -o /tmp/guac.dts 2>/dev/null && echo "dtc OK ($(wc -l < /tmp/guac.dts) lines)"
echo "--- model/compatible"
grep -m2 -E 'model =|compatible = "oneplus' /tmp/guac.dts
echo "--- framebuffer (chosen)"
grep -A8 'simple-framebuffer' /tmp/guac.dts | head -12
echo "--- usb dr_mode"
grep -B2 -A6 'dr_mode' /tmp/guac.dts | head -14
echo "--- ufs status"
grep -A3 'ufs@1d84000' /tmp/guac.dts | head -6
echo "--- touchscreen"
grep -A5 's6sy761' /tmp/guac.dts | head -8
echo "=== boot.img"
ls -lh /root/op7p/out/ 2>/dev/null || true
if [ -f /root/op7p/out/boot.img ]; then
    strings -a /root/op7p/out/boot.img | grep -m1 'console=tty0' || true
    ls -l /root/op7p/out/boot.img
fi

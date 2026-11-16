#!/bin/bash
set -u
python3 - <<'PY'
src='/root/hotdog/aports/device/testing/linux-oneplus-hotdog-mainline616/0012-drm-msm-enable-native-hotdog-dsc-panel.patch'
lines=open(src).read().splitlines(keepends=True)
out=[]; keep=False
for ln in lines:
    if ln.startswith('diff --git '):
        keep = 'panel-samsung-oneplus-dsc.c' in ln
    elif keep:
        # 新文件内容以 '+' 开头
        if ln.startswith('+++') or ln.startswith('---'):
            continue
        if ln.startswith('+'):
            out.append(ln[1:])
open('/root/panel-hotdog.c','w').write(''.join(out))
print("extracted lines:", len(out))
PY
echo "=== 驱动结构"
grep -n -e 'static const struct drm_display_mode' -e 'hdisplay' -e 'vdisplay' -e 'clock' -e 'slice' -e 'compatible' -e 'vddio' -e 'avdd' /root/panel-hotdog.c | head -20
echo "=== init/命令表规模"
grep -c 'dsi_generic_write\|mipi_dsi_dcs_write\|0x' /root/panel-hotdog.c | head -1
echo "=== 关键函数"
grep -n -e 'oneplus_dsc_prepare' -e 'oneplus_dsc_on' -e 'oneplus_dsc_probe' -e 'backlight' /root/panel-hotdog.c | head -10

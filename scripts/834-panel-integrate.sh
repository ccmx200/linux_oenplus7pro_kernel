#!/bin/bash
set -uo pipefail
K=/root/kbuild/linux
cp -f /root/panel-hotdog.c "$K/drivers/gpu/drm/panel/panel-samsung-oneplus-dsc.c"
echo "driver copied: $(wc -l < $K/drivers/gpu/drm/panel/panel-samsung-oneplus-dsc.c) lines"

# Kconfig 条目
python3 - <<'PY'
p='/root/kbuild/linux/drivers/gpu/drm/panel/Kconfig'
s=open(p).read()
if 'DRM_PANEL_SAMSUNG_ONEPLUS_DSC' not in s:
    entry = '''
config DRM_PANEL_SAMSUNG_ONEPLUS_DSC
	tristate "Samsung OnePlus DSC AMOLED panel"
	depends on OF
	depends on DRM_MIPI_DSI
	depends on BACKLIGHT_CLASS_DEVICE
	help
	  Say Y if you want to enable support for the Samsung OnePlus DSC
	  AMOLED panel found in OnePlus 7/7T series.
'''
    s = s.rstrip() + '\n' + entry
    open(p,'w').write(s)
    print("kconfig added")
else:
    print("kconfig exists")
PY

# Makefile 条目
python3 - <<'PY'
p='/root/kbuild/linux/drivers/gpu/drm/panel/Makefile'
s=open(p).read()
if 'panel-samsung-oneplus-dsc' not in s:
    s = s.rstrip() + '\nobj-$(CONFIG_DRM_PANEL_SAMSUNG_ONEPLUS_DSC) += panel-samsung-oneplus-dsc.o\n'
    open(p,'w').write(s)
    print("makefile added")
else:
    print("makefile exists")
PY

echo "=== dsi_host 里 dsc_slice_per_pkt 的赋值"
grep -n 'dsc_slice_per_pkt' "$K/drivers/gpu/drm/msm/dsi/dsi_host.c"
echo "=== drm_dsc.h 字段"
grep -n 'dsc_slice_per_pkt' "$K/include/drm/display/drm_dsc.h" || echo "(缺字段)"
echo "=== 驱动里的 dsc 字段用法"
grep -n 'dsc_slice_per_pkt\|dsc_slice_per_pkt' "$K/drivers/gpu/drm/panel/panel-samsung-oneplus-dsc.c" | head -3

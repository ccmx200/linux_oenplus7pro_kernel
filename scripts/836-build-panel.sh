#!/bin/bash
set -uo pipefail
K=/root/kbuild/linux
F=$K/drivers/gpu/drm/panel/panel-samsung-oneplus-dsc.c
cp -f "$F" /root/panel-dsc-orig.c
python3 - "$F" <<'PY'
import sys
p=sys.argv[1]; s=open(p).read()
s = s.replace("""	dsi->mode_flags = MIPI_DSI_MODE_NO_EOT_PACKET |
			  MIPI_DSI_CLOCK_NON_CONTINUOUS |
			  MIPI_DSI_MODE_LPM;""",
"""	dsi->mode_flags = MIPI_DSI_MODE_NO_EOT_PACKET |
			  MIPI_DSI_CLOCK_NON_CONTINUOUS |
			  MIPI_DSI_MODE_LPM |
			  MIPI_DSI_MODE_DSC_ALL_SLICES_IN_PKT;""")
s = s.replace("\tctx->dsc.dsc_slice_per_pkt = 2;\n", "")
open(p,"w").write(s)
print("adapted to 7.3 DSC API")
PY
echo "=== 编译 panel 模块"
cd "$K"
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- M=drivers/gpu/drm/panel CONFIG_DRM_PANEL_SAMSUNG_ONEPLUS_DSC=m modules 2>&1 | tail -10
ls -lh drivers/gpu/drm/panel/panel-samsung-oneplus-dsc.ko 2>/dev/null

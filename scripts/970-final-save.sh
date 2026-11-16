#!/bin/bash
set -uo pipefail
C=/mnt/c/Users/cuicanmx/Documents/deepseek-harness/default-workspace/oneplus7pro
OUT=$C/nura-out
K=/root/kbuild/linux
# 保存产物
cp -f /root/panel3-final.dtb "$OUT/sm8150-guac-panel-dsi-final.dtb" 2>/dev/null
cp -f "$K/arch/arm64/boot/Image" "$OUT/Image-wdt-disabled" 2>/dev/null
cp -f "$K/drivers/gpu/drm/panel/panel-samsung-oneplus-dsc.ko" "$OUT/" 2>/dev/null
cp -f "$K/drivers/net/wireless/ath/ath10k/ath10k_core.ko" "$OUT/ath10k_core-fixed.ko" 2>/dev/null
cp -f "$K/drivers/net/wireless/ath/ath10k/ath10k_snoc.ko" "$OUT/ath10k_snoc-fixed.ko" 2>/dev/null
cp -f /root/ath10k-fixes.patch "$OUT/" 2>/dev/null
cp -f /root/head.S.bak "$OUT/head.S.orig" 2>/dev/null

cat >> "$C/STATUS.md" <<'EOF'

## 2026-11-17 屏幕打通（DRM + DSI DSC 面板，connected）

**现象**：之前一启用 mdss 就整机复位（看起来像 Qualcomm 崩溃）。
**根因**：mdss 初始化卡住时被 **继承的 APSS 看门狗**复位。
**修复**（来自 hotdog 的 `experimental-mainline-entry-disable-apss-wdt.patch`）：
`arch/arm64/kernel/head.S` 在 `__cpu_setup` 后写 `0x17c10000 + 0x08 = 0`（WDT0_EN=0）。

**面板**：hotdog 的 `panel-samsung-oneplus-dsc.c` 与 guac 原厂面板参数完全一致
（1440×3120、DSC slice 720×65、per-pkt 2、hfp16/hbp8/hpw8、vbp1156/vfp400/vpw28），
已移植到 7.3 树并适配 `MIPI_DSI_MODE_DSC_ALL_SLICES_IN_PKT`。

**DTS**：
```
&mdss { status="okay"; };  &mdss_mdp { status="okay"; };
&mdss_dsi0 { status="okay"; vdda-supply=<&vreg_l3c_1p2>;
   panel@0 { compatible="samsung,oneplus-dsc"; vddio-supply=<&vreg_l14a_1p8>;
             avdd-supply=<&panel_avdd_1p8>; reset-gpios=<&tlmm 6 GPIO_ACTIVE_LOW>;
             pinctrl-0=<&panel_te_default>; port { panel_in: endpoint { remote-endpoint=<&mdss_dsi0_out>; }; }; }; };
&mdss_dsi0_phy { status="okay"; vdds-supply=<&vreg_l5a_0p875>; };
&mdss_dsi0_out { data-lanes=<0 1 2 3>; remote-endpoint=<&panel_in>; status="okay"; };
```
＋ `panel_avdd_1p8` 固定 1.8V、TE pinctrl（gpio8, mdp_vsync）、`/etc/modules-load.d/panel.conf`。

**结果**：`card0`、`card0-DSI-1 status=connected`、backlight 1023、msmdrmfb fb0；
开机自动生效，不再崩溃。

## 2026-11-17 WiFi 最终可用（已联网）

`wlan0: connected to cuicanmx_5G`，IP 192.168.111.247/24，`ping 223.5.5.5` 0% 丢包。
配方见上一节（ath10k 补丁 + hotdog WLAN 固件 + guac modem 固件 + wifi 节点 DTB）。
EOF
echo "STATUS updated"
ls -lh "$OUT" | tail -8

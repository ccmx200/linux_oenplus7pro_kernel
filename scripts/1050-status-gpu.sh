#!/bin/bash
set -uo pipefail
C=/mnt/c/Users/cuicanmx/Documents/deepseek-harness/default-workspace/oneplus7pro
cat >> "$C/STATUS.md" <<'EOF'

## 2026-11-17 触摸（S6SY761）打通

**根因**：`i2c17` 挂在 **qupv3_id_2**（0xc80000）下，而 DTS 只启用了 qupv3_id_1 → 没有任何 I2C 适配器 → 触摸不可能 probe。

**修复**：
```
&qupv3_id_2 { status = "okay"; };
&gpi_dma2  { status = "okay"; };
&i2c17 { touchscreen@48 {
    compatible = "samsung,s6sy761";
    interrupts = <122 0x2008>;
    vdd-supply = <&vreg_l17a_3p0>;
    touchscreen-size-x = <1440>;
    touchscreen-size-y = <3120>;
    touchscreen-inverted-y;
}; };
```
+ `/etc/modules-load.d/touch.conf`（s6sy761）。

**结果**：`s6sy761 0-0048` probe 成功，`/dev/input/event1` 出现，触摸可用（用户确认 OK）。

## 2026-11-17 GPU（Adreno 640）打通

**修复**（参照 hotdog）：
```
&gmu { status = "okay"; };
&gpu { status = "okay"; zap-shader { firmware-name = "qcom/sm8150/oneplus7/a640_zap.mbn"; }; };
```
固件：`a630_sqe.fw`、`a640_gmu.bin` → `/lib/firmware/qcom/`；`a640_zap.mbn` → `/lib/firmware/qcom/sm8150/oneplus7/`。

**结果**：GMU firmware v2.0.261 加载、adreno 绑定 `a3xx_ops`、`/dev/dri/renderD128`、
devfreq 257~585 MHz、**Turnip Adreno 640 Vulkan 1.3 可用**。
（vdd/vddcx 仍是 dummy，用 bootloader 设定电压，与 hotdog 一致。）
EOF
echo status_updated
ls -lh "$C/nura-out" | grep -E "gpu|touch|panel" | head

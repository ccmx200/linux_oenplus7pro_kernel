#!/bin/bash
# 把 7 Pro 内核改动整理成一个可复现的仓库并推送
set -uo pipefail
TOKEN="${GH_TOKEN:?need token}"
REPO="ccmx200/linux_oenplus7pro_kernel"
W=/root/kernel-repo
rm -rf "$W"
git clone "https://x-access-token:${TOKEN}@github.com/${REPO}.git" "$W" 2>&1 | tail -2
cd "$W"
git config user.email "op7p@local"
git config user.name "op7p builder"

mkdir -p dts patches config scripts docs

# 1) 我们新增/修改的 DTS
K=/root/kbuild/linux
cp -f "$K/arch/arm64/boot/dts/qcom/sm8150-oneplus-common.dtsi" dts/ 2>/dev/null
cp -f "$K/arch/arm64/boot/dts/qcom/sm8150-oneplus-guacamole.dts" dts/ 2>/dev/null

# 2) 内核配置
cp -f "$K/.config" config/kernel-7.3.0-sm8150.config
cp -f /root/kernel-deb/raphael.config config/raphael.config

# 3) 我们的构建/修复脚本
cp -f /mnt/c/Users/cuicanmx/Documents/deepseek-harness/default-workspace/oneplus7pro/wsl/*.sh scripts/ 2>/dev/null

# 4) 关键补丁说明（Makefile 改动等）
cat > patches/0001-dts-add-oneplus-guacamole.patch <<'EOF'
--- a/arch/arm64/boot/dts/qcom/Makefile
+++ b/arch/arm64/boot/dts/qcom/Makefile
@@ -1,3 +1,4 @@
+dtb-$(CONFIG_ARCH_QCOM)	+= sm8150-oneplus-guacamole.dtb
 # SPDX-License-Identifier: GPL-2.0
 # Copyright (c) 2017-2019, The Linux Foundation. All rights reserved.
EOF

cat > patches/0002-Makefile.package-allow-missing-builddeps.patch <<'EOF'
# 本地交叉编译 bindeb-pkg 时跳过 dpkg 构建依赖检查（libssl-dev:arm64 之类）
--- a/scripts/Makefile.package
+++ b/scripts/Makefile.package
@@
-	+$(strip dpkg-buildpackage \
+	+$(strip dpkg-buildpackage -d \
EOF

# 5) DTB 后处理脚本说明
cat > docs/DTB-POSTPROCESS.md <<'EOF'
# DTB 后处理（必须在刷机前做）

1. `/memory` 补 6GB 三段（OnePlus 7 Pro 6G，ABL 不会在 systemd-boot 链里补）：

```
memory@80000000 { reg = <0x00 0x80000000 0x00 0x3cc00000>; };
memory@c0000000 { reg = <0x00 0xc0000000 0x00 0x80000000>; };
memory@100000000 { reg = <0x01 0x00000000 0x00 0xc0000000>; };
```

2. PM8150/PM8150L 的每个 regulator 子节点加 `qcom,no-readback;`（Project Mu UEFI 不给 RPMh 读通道），
   并删除 `pm8009-rpmh-regulators` 节点，否则内核在 RPMh 读超时后崩溃。

3. systemd-boot 条目需要：

```
linux /vmlinuz
initrd /initrd.img
devicetree /dtbs/qcom/sm8150-oneplus-guacamole.dtb
options root=UUID=ee8d3593-59b1-480e-a3b6-4fefb17ee7d8 rw loglevel=7 ignore_loglevel console=tty0
```
EOF

cat > README.md <<'EOF'
# OnePlus 7 Pro (guacamole) Linux 内核构建

基于 [GengWei1997/linux](https://github.com/GengWei1997/linux) `raphael-v7.3.0`（SM8150，7.3.0），
加上 guacamole 设备树，用于 OnePlus 7 Pro（6G/128G）实际硬件测试。

## 当前状态

- ✅ 内核启动、UFS 正常、SSH 可用（USB NCM，172.16.42.1）
- ✅ RPMh 崩溃已修（`qcom,no-readback` + 删除 pm8009 regulators）
- ⚠️ 显示：mainline 的 guac DTS 里 `display-subsystem@ae00000` / `dsi@ae94000` 仍是 disabled，
  面板（`panel-samsung-ams639rq08`，需 vdd3p3/vddio/vsn/vsp 四路供电）尚未接入
- ⚠️ WiFi：`ath10k_snoc` 能 probe（WCN3990），固件已放好，但没出 `wlan0`，待查 QMI

## 构建

```bash
git clone https://github.com/GengWei1997/linux -b raphael-v7.3.0 linux
cd linux
cp arch/arm64/configs/raphael.config .   # 或 config/raphael.config
cp ../dts/* arch/arm64/boot/dts/qcom/
echo 'dtb-$(CONFIG_ARCH_QCOM) += sm8150-oneplus-guacamole.dtb' >> arch/arm64/boot/dts/qcom/Makefile
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- defconfig raphael.config
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- -j$(nproc) Image.gz dtbs modules
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- -j$(nproc) bindeb-pkg   # 需要 -d 补丁
```

## DTB 后处理

见 `docs/DTB-POSTPROCESS.md`（6GB 内存 + no-readback + systemd-boot 条目）。

## 硬件事实（实测）

- 内存 6GB，三段布局见上
- UFS：`KLUDG4UHDB-B2D1`
- 面板：1440×3120，command mode（DSC），simplefb 无法点亮
- WiFi/BT：WCN3990（`ath10k_snoc` + `qca,wcn3990`）
- 指纹：`samsung,s6sy761`
EOF

git add -A
git commit -m "OnePlus 7 Pro (guacamole) kernel: DTS, config, build & DTB postprocess docs" 2>&1 | tail -3
git push -u origin HEAD 2>&1 | tail -5
echo "=== pushed"

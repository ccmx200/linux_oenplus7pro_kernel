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

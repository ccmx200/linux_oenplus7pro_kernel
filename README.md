# OnePlus 7 Pro (guacamole) — Linux 7.3.0 mainline 内核

一加 7 Pro（`guacamole`，SM8150 / Snapdragon 855，6GB+128GB）的主线内核移植，基于
GengWei1997 的 `raphael-v7.3.0` 树，补齐了 WiFi、DSI DSC 面板、触摸和 GPU。

## 设备状态（已实测）

| 硬件 | 状态 | 说明 |
|---|---|---|
| 启动 | ✅ | U-Boot + systemd-boot（ESP 位于 userdata），6GB 内存布局 |
| 屏幕 | ✅ | 原生 DSI + Samsung OnePlus DSC 面板，1440×3120，背光可调 |
| 触摸 | ✅ | Samsung S6SY761（i2c17 / qupv3_id_2） |
| WiFi | ✅ | WCN3998：`wlan0` 可扫描/连接，ath10k + MSA reclaim/INCOMPATIBLE_STATE 修复 |
| GPU | ✅ | Adreno 640 + GMU，Turnip Vulkan 1.3 |
| 温度 | ✅ | 27 个 thermal zone（CPU/GPU/PMIC），hwmon 暴露 input/crit |
| 调制解调器 | ✅ | MPSS 启动，QRTR/QMI 服务正常 |
| USB | ✅ | USB NCM 网络 + SSH（172.16.42.1） |

## 关键补丁

- `drivers/net/wireless/ath/ath10k/`：MSA reclaim、`QMI_ERR_INCOMPATIBLE_STATE` 恢复、wakeup
  （移植自 `Sr-0w/hotdog-linux-bringup`）
- `drivers/gpu/drm/panel/panel-samsung-oneplus-dsc.c`：OnePlus DSC 面板驱动
- `arch/arm64/kernel/head.S`：入口关闭 APSS 看门狗（否则 mdss 初始化卡住会整机复位）
- `drivers/thermal/thermal_hwmon.c`：qcom tsens 的 hwmon 温度阈值回退
- DTS：`arch/arm64/boot/dts/qcom/sm8150-oneplus-{common,guacamole}.dts*`
- 配置：`arch/arm64/configs/raphael.config`

## 构建

```bash
# 依赖
sudo apt install gcc-aarch64-linux-gnu bc bison flex libssl-dev libelf-dev \
                 kmod cpio rsync zstd libdw-dev dpkg-dev

# 配置
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- defconfig raphael.config

# 内核 + deb 包
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- -j$(nproc)
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- -j$(nproc) bindeb-pkg
```

GitHub Actions 会在每次推送时自动编译并上传 deb 产物（见 `.github/workflows/build-kernel.yml`）。

## 设备树要点

```dts
&gmu { status = "okay"; };
&gpu { status = "okay"; zap-shader { firmware-name = "qcom/sm8150/oneplus7/a640_zap.mbn"; }; };

&mdss { status = "okay"; };
&mdss_dsi0 { status = "okay"; vdda-supply = <&vreg_l3c_1p2>; panel@0 { ... }; };
&mdss_dsi0_phy { status = "okay"; vdds-supply = <&vreg_l5a_0p875>; };

&qupv3_id_2 { status = "okay"; };
&gpi_dma2 { status = "okay"; };
&i2c17 { touchscreen@48 { compatible = "samsung,s6sy761"; ... }; };

&wifi { status = "okay"; vdd-0.8-cx-mx-supply = <&vreg_l1a_0p75>; ... };
```

## 固件（不入库）

- `qcom/sm8150/oneplus7/`：guac 原厂 OOS11 `modem.*`、`wlanmdsp.mbn`（hotdog 版 `WLAN.HL.3.0.c8`）、`a640_zap.mbn`
- `ath10k/WCN3990/hw1.0/`：`board-2.bin`、`firmware-5.bin`（hotdog 套件）
- `qcom/`：`a630_sqe.fw`、`a640_gmu.bin`

## 仓库结构

| 路径 | 内容 |
|---|---|
| `dts/` | 设备树源文件 |
| `config/` | 内核配置 |
| `patches/` | 补丁（ath10k / 面板 / 看门狗等） |
| `scripts/` | 构建、刷机、调试脚本 |
| `docs/` | 说明文档 |
| `.github/workflows/` | CI 构建 |

分支：
- `main`：文档、DTS、补丁、脚本
- `kernel-7.3.0-op7p`：完整内核源码（含全部改动）

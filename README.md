# OnePlus 7 Pro · 主线 Linux

**在 OnePlus 7 Pro（`guacamole` / SM8150 / Snapdragon 855）上运行主线 Linux 与 Ubuntu 桌面。**

<p align="center">
  <img alt="kernel" src="https://img.shields.io/badge/kernel-7.3.0-1f6feb">
  <img alt="soc" src="https://img.shields.io/badge/SoC-SM8150-8957e5">
  <img alt="device" src="https://img.shields.io/badge/device-OnePlus%207%20Pro-eb6834">
  <img alt="distro" src="https://img.shields.io/badge/distro-Ubuntu%20GNOME-e95420">
  <img alt="license" src="https://img.shields.io/badge/license-GPL--2.0-2ea44f">
  <img alt="ci" src="https://img.shields.io/badge/CI-GitHub%20Actions-2088ff">
</p>

---

## 目录

- [硬件支持状态](#硬件支持状态)
- [启动链](#启动链)
- [快速开始](#快速开始)
- [目录结构](#目录结构)
- [文档](#文档)
- [已知问题](#已知问题)
- [致谢](#致谢)

---

## 硬件支持状态

| 模块 | 状态 | 说明 |
|:--|:--:|:--|
| 启动 | ✅ | ABL → 自建 U-Boot → systemd-boot（ESP 位于 `userdata`） |
| 屏幕 | ✅ | 原生 DSI + Samsung OnePlus DSC 面板，1440×3120，背光可调 |
| 触摸 | ✅ | Samsung S6SY761（`i2c17` / `qupv3_id_2`，IRQ 122，reset 54） |
| WiFi | ✅ | WCN3998 + `ath10k_snoc`，扫描/连接正常 |
| GPU | ✅ | Adreno 640 + GMU v2.0.261，Turnip Vulkan 1.3 |
| 电池 | ✅ | 外置电量计 `ti,bq27411` @ `i2c8` |
| 温度 | ✅ | 27 个 thermal zone + `hwmon` 阈值 |
| NFC | 🟡 | `nfc0` 枚举成功，存在 I2C 读错误 |
| 蓝牙 | 🟡 | `hci0` 出现，待补 BT 使能脚 |
| 声音 | 🟡 | ADSP/APR 已通，SLIMbus（BAM DMA）待修 |
| 摄像头 | ❌ | 传感器驱动待移植 |
| USB 网络 | ✅ | NCM `172.16.42.1/24` + SSH |
| 桌面 | ✅ | Ubuntu GNOME + 中文 + ibus |

---

## 启动链

```
        ┌──────────┐   boot_a(96M)   ┌────────────┐   ESP(userdata p1)   ┌──────────────┐
  ABL → │  U-Boot  │ ──────────────→ │ bootflow / │ ───────────────────→ │ systemd-boot │
        └──────────┘                 │ bootmgr    │                      └──────┬───────┘
                                                                                │
                    ┌───────────────────────────────────────────────────────────┘
                    ▼
        /vmlinuz  +  /initrd.img  +  /dtbs/qcom/sm8150-oneplus-guacamole.dtb
```

- U-Boot 用 `bootflow scan -b` 直接扫描 ESP 上的 systemd-boot（不依赖易失效的 EFI 变量）
- Linux 里 `reboot bootloader` 可直接进 fastboot（PON reboot-mode）
- fastboot 恢复：`fastboot flash userdata <img>` + `fastboot erase misc`

---

## 快速开始

### 获取内核产物（推荐）

推送代码后 GitHub Actions 自动编译，或在 **Actions → build-kernel** 下载：

```
oneplus7pro-kernel-debs
 ├── linux-image-<ver>.deb
 └── linux-headers-<ver>.deb
```

### 本地构建

```bash
sudo apt install gcc-aarch64-linux-gnu bc bison flex libssl-dev libelf-dev \
                 kmod cpio rsync zstd libdw-dev dpkg-dev device-tree-compiler

make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- defconfig raphael.config
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- -j$(nproc) Image
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- -j$(nproc) bindeb-pkg
```

### 部署 DTB（必须后处理）

见 [docs/DTB-POSTPROCESS.md](docs/DTB-POSTPROCESS.md)：内存节点、`qcom,no-readback`、删除 `pm8009`。

### 刷入系统镜像

```bash
fastboot flash userdata rootfs-desktop-op7p.img
fastboot erase misc
fastboot --set-active=a
fastboot reboot
```

镜像构建方法见 [docs/image-build.md](docs/image-build.md)。

---

## 目录结构

| 路径 | 内容 |
|:--|:--|
| `dts/` | 板级设备树源文件（`sm8150-oneplus-*`） |
| `config/` | 内核配置 `raphael.config` |
| `patches/` | 功能补丁（ath10k / 面板 / 看门狗等） |
| `scripts/` | 构建、刷机、调试脚本（编号流水线） |
| `docs/` | 文档 |
| `.github/workflows/` | CI：内核编译 + Artifact + Release |

分支：

| 分支 | 内容 |
|:--|:--|
| `main` | 文档、DTS、补丁、脚本、CI |
| `kernel-7.3.0-op7p` | 完整内核源码（含全部改动） |

---

## 文档

| 文档 | 说明 |
|:--|:--|
| [docs/PITFALLS.md](docs/PITFALLS.md) | **技术踩坑记录**（启动/显示/WiFi/U-Boot 按键/构建等） |
| [docs/DTB-POSTPROCESS.md](docs/DTB-POSTPROCESS.md) | DTB 后处理三步 |
| [docs/image-build.md](docs/image-build.md) | Ubuntu GNOME + 中文 + NCM 镜像构建 |
| [docs/UBOOT.md](docs/UBOOT.md) | U-Boot 构建、按键与启动方式 |

---

## 已知问题

- 声音：SLIMbus BAM DMA 初始化会导致卡死/崩溃，需要按主线 `qcom-ngd-ctrl` 重构
- 摄像头：hotdog 的 IMX586/IMX481/IMX471 补丁与 7.3 冲突，需手工移植
- 触摸休眠唤醒：`s6sy761` 已加 reset-gpio + boot-complete 轮询，待实测
- 蓝牙：缺 BT 使能脚；NFC：I2C 读偶发 `-121`
- GPU：偶发 `source=CCU` fault

细节与根因见 [docs/PITFALLS.md](docs/PITFALLS.md)。

---

## 致谢

- [GengWei1997/linux](https://github.com/GengWei1997) —— 基线内核树
- [Sr-0w/hotdog-linux-bringup](https://github.com/Sr-0w/hotdog-linux-bringup) —— 一加 7T Pro 主线移植（面板/ath10k/音频/NFC 等大量参考）
- [Nura](https://gitlab.nura.eco) —— SM8150 主线树
- postmarketOS / U-Boot 社区

> 仅供学习研究。刷机有风险，请先备份并确认可恢复路径。

# 技术踩坑记录（PITFALLS）

> 本文件专门记录移植过程中**真实踩过**的坑：现象 → 根因 → 修复 → 涉及文件。
> 与 README 的功能说明分开维护，便于检索与避免重踩。

---

## 目录

**启动与引导**
1. [mdss 一初始化就整机复位](#1-mdss-一初始化就整机复位)
2. [U-Boot 用 bootefi bootmgr 开机直接进菜单](#2-u-boot-用-bootefi-bootmgr-开机直接进菜单)
3. [如何在按键坏掉时进入 fastboot](#3-如何在按键坏掉时进入-fastboot)

**U-Boot 音量键**
4. [U-Boot 不认 PM8150 GPIO](#4-u-boot-不认-pm8150-gpio)
5. [SPMI 通道表缺失 pid 0xc0–0xcf](#5-spmi-通道表缺失-pid-0xc00xcf)
6. [pinctrl input-enable 不生效，按键恒为按下](#6-pinctrl-input-enable-不生效按键恒为按下)
7. [U-Boot 构建会冲掉板级 DTS 改动](#7-u-boot-构建会冲掉板级-dts-改动)
8. [usbacm 进 stdout 会卡死启动](#8-usbacm-进-stdout-会卡死启动)

**设备树与显示**
9. [DTB 后处理三件套](#9-dtb-后处理三件套)
10. [面板驱动没加载 → 无 DRM 设备](#10-面板驱动没加载--无-drm-设备)

**WiFi**
11. [guac 原厂固件在 modem 里 assert](#11-guac-原厂固件在-modem-里-assert)
12. [QMI_ERR_INCOMPATIBLE_STATE (90)](#12-qmi_err_incompatible_state-90)
13. [board-2.bin 格式错误](#13-board-2bin-格式错误)

**音频**
14. [IPCRTR 通道劫持 APR](#14-ipcrtr-通道劫持-apr)
15. [q6asm-dai 报 No dais found in DT](#15-q6asm-dai-报-no-dais-found-in-dt)
16. [slimbam（BAM DMA）导致崩溃/卡启动](#16-slimbbam-bam-dma导致崩溃卡启动)

**触摸**
17. [触摸完全不存在](#17-触摸完全不存在)
18. [触摸轴参数缺失](#18-触摸轴参数缺失)
19. [休眠唤醒后触摸失效](#19-休眠唤醒后触摸失效)

**构建与运维**
20. [PowerShell 内联命令破坏引号](#20-powershell-内联命令破坏引号)
21. [镜像构建的 bootstrap/loop/磁盘坑](#21-镜像构建的-bootstraploop磁盘坑)
22. [GitHub 大包推送 500](#22-github-大包推送-500)

---

## 1. mdss 一初始化就整机复位

**现象**：使能 `&mdss` 后，内核刚进 mdss 就整机复位，串口/屏幕全黑，像"崩溃"。

**根因**：APSS 看门狗未关闭。mdss 初始化若卡住，WDT 到点直接复位，内核来不及打印。

**修复**：`arch/arm64/kernel/head.S` 中 `__cpu_setup` 之后写 `0x17c10000 + 0x08 = 0`（WDT0_EN）关闭看门狗。

**文件**：`arch/arm64/kernel/head.S`

---

## 2. U-Boot 用 bootefi bootmgr 开机直接进菜单

**现象**：屏幕显示
```
Loading Boot0000 'scsi 1' failed
Loading Boot0001 'scsi 1' failed
...
```
然后落到 U-Boot 菜单，不进系统。

**根因**：`bootefi bootmgr` 优先使用 EFI 启动变量（`Boot####`）。这些变量是早期写入的，指向已失效的设备路径（`scsi 1`），全部失败后 `bootcmd` 落到 `run menucmd`。

**修复**：改用 bootstd 的 bootflow，直接扫块设备上的 EFI 程序：
```ini
bootcmd=bootflow scan -b; pause; run menucmd
```
（`CONFIG_BOOTSTD` / `CONFIG_CMD_BOOTFLOW` 已启用）

**文件**：`board/qualcomm/qcom-phone.env`

---

## 3. 如何在按键坏掉时进入 fastboot

**办法 A（推荐）**：Linux 里执行 `reboot bootloader` —— 依赖 DTS 中的 SM8150 IMEM `reboot-mode`（hotdog `0156` 的处理），已验证可用。

**办法 B**：长按电源 10 秒关机 → **按住音量下**插 USB。这个按键由 **ABL** 识别，不依赖 U-Boot。

**办法 C**：`fastboot flash userdata <镜像>` + `fastboot erase misc` 恢复（ABL 的启动失败计数存在 `misc`）。

---

## 4. U-Boot 不认 PM8150 GPIO

**现象**：`button list` 为空，音量键完全不存在。

**根因**：`drivers/gpio/qcom_spmi_gpio.c` 的 `of_match` 表里只有 `pm6150l/pm6350/pm660l/pm7325/pm8550*` 等，**没有 `qcom,pm8150-gpio`**；而 PM8150 dtsi 节点的首个 compatible 就是它。

**修复**：给表加 `qcom,pm8150-gpio`、`qcom,pm8150b-gpio`、`qcom,pm8150l-gpio`。

**文件**：`drivers/gpio/qcom_spmi_gpio.c`

---

## 5. SPMI 通道表缺失 pid 0xc0–0xcf

**现象**：GPIO 寄存器读返回 `-EINVAL`，`incorrect block type` 或读值恒定。

**根因**：`msm_spmi_probe()` 只扫描一次 APID 表并缓存；PM8150 的 GPIO 外设（pid `0xc0..0xcf`）在某些仲裁器版本/固件上会漏掉，之后所有访问都失败。

**修复**：在 `msm_spmi_read/write` 里增加按需查找 `msm_spmi_lookup_channel()`——首次访问未命中时重扫 APID 表并缓存（对照主线 `spmi-pmic-arb.c` 的 `ppid = sid << 8 | addr >> 8`）。

**文件**：`drivers/spmi/spmi-msm.c`

---

## 6. pinctrl input-enable 不生效，按键恒为按下

**现象**：`button list` 显示 `Volume Up on` / `Volume Down on`（永远按下），按键无反应。

**根因**：U-Boot 的 pinctrl 没有把 `input-enable` 落到 PM8150 的 `DIG_IN_CTL`/`EN_CTL`，导致 `RT_STS` 读到恒定 0；经 `GPIO_ACTIVE_LOW` 反相后按钮恒为"按下"。

**修复**：在 `qcom_spmi_pmic_gpio_probe()` 里对音量键引脚（pad 6/7）直接写：
```c
EN_CTL     |= BIT(7);   // 外设使能
DIG_IN_CTL |= BIT(7);   // 输入缓冲使能
pad->input_enabled = true;
```
验证手段：启动时连续 3 次 `button list`，读数随按住/松开变化即成功。

**文件**：`drivers/gpio/qcom_spmi_gpio.c`

---

## 7. U-Boot 构建会冲掉板级 DTS 改动

**现象**：明明改了 `sm8150-oneplus-guacamole.dts` 的按键，重新编译后不生效。

**根因**：`wsl/147-ubuild.sh` 每次都会从 `sm8150-xiaomi-raphael.dts` 重新生成 guacamole DTS，覆盖手工改动。

**修复**：把增量补丁脚本 `wsl/1665-apply-guac-dts.sh` 挂进 147 的构建流程，生成后立即应用（音量下键、pinctrl、`power-source`）。

---

## 8. usbacm 进 stdout 会卡死启动

**现象**：把 `usbacm` 加入默认 `stdin/stdout/stderr` 后，U-Boot 卡住不启动，也没有 COM 口。

**根因**：`usbacm` 控制台设备只有在 USB gadget 被初始化后才存在；在 console 初始化阶段引用它会失败并卡住。

**修复**：默认控制台恢复 `serial,button-kbd` / `serial,vidconsole`；调试改用**屏幕打印**（vidconsole）或先初始化 gadget 再切换。

---

## 9. DTB 后处理三件套

**现象**：直接用 `make dtbs` 产出的 DTB 启动失败/内存不对/regulator 读写异常。

**必须做**（每次部署前）：

1. **6GB 内存节点**（guac 是 6G 版本）
   ```
   memory@80000000  reg = <0x00 0x80000000 0x00 0x3cc00000>
   memory@c0000000  reg = <0x00 0xc0000000 0x00 0x80000000>
   memory@100000000 reg = <0x01 0x00000000 0x00 0xc0000000>
   ```
2. 给 `pm8150` / `pm8150l` 下 31 个 regulator 子节点加 `qcom,no-readback`
3. 删除 `pm8009-rpmh-regulators` 节点

**脚本**：`wsl/1160-port-pon.sh`、`wsl/1161-final-dtb.sh`、`wsl/1304-touch-port.sh` 里的后处理片段。

---

## 10. 面板驱动没加载 → 无 DRM 设备

**现象**：面板 DTB 能启动，但 `/dev/dri` 不存在，屏幕无显示。

**根因**：`panel-samsung-oneplus-dsc.ko` 没被加载（驱动是模块）。

**修复**：部署模块 + `/etc/modules-load.d/panel.conf`。

**注意**：内核 `.config` 必须包含 `CONFIG_DRM_PANEL_SAMSUNG_ONEPLUS_DSC=m`（否则镜像里没有这个模块）。

---

## 11. guac 原厂固件在 modem 里 assert

**现象**：WiFi 启用后 modem 侧 `wlan_process` assert，报 `WLAN RT:0x1078/0x2076/0x2077/0x2078`，整机重启。

**根因**：guac OOS11 的 `wlanmdsp.mbn`（`WLAN.HL.3.2.0`）与 ath10k 的启动序列不兼容。

**修复**：改用 **hotdog（一加 7T Pro）的 `wlanmdsp.mbn`（`WLAN.HL.3.0.c8-00232`）** + hotdog 的 `board-2.bin` / `firmware-5.bin` + ath10k 三个补丁。

**文件**：`/lib/firmware/qcom/sm8150/oneplus7/wlanmdsp.mbn`、`ath10k/WCN3990/hw1.0/*`、`drivers/net/wireless/ath/ath10k/{qmi.c,qmi.h,snoc.c}`

---

## 12. QMI_ERR_INCOMPATIBLE_STATE (90)

**现象**：`config request rejected: 90`，WiFi 起不来。

**根因**：固件里 WLAN 仍是 enabled 状态，重新初始化被拒绝。

**修复**：补丁里把 90 映射为 `-EBUSY` 并重试：先 `ath10k_qmi_wlan_disable()`，再 `ath10k_qmi_reclaim_msa()`。

---

## 13. board-2.bin 格式错误

**现象**：`board_file api 0 crc32 0`、`failed to recalculate rts/cts prot for vdev 0: -108`，WiFi 不可用。

**根因**：用 `ath10k-bdencoder` 把 guac 原厂 `bdwlan.bin` 包装成 `board-2.bin` 时格式不合法；官方 linux-firmware 的 board-2 也与该模块不匹配。

**修复**：直接使用 hotdog 的 `board-2.bin`（876K）。

---

## 14. IPCRTR 通道劫持 APR

**现象**：ADSP 能启动，但 `APR: Wrong hdr size:0`、`slim-ngd: QMI wait timeout`，声卡不出现。

**根因**：为 WiFi 调试时给 `sm8150.dtsi` 的所有 glink edge 加了 `"IPCRTR"` 通道，导致 APR 音频通道被抢占。

**修复**：删除 4 处 `"IPCRTR", `，APR/GPR 服务随即全部注册（`aprsvc:service:4:3/4:4/4:7/4:8`）。WiFi 不受影响（已验证）。

---

## 15. q6asm-dai 报 No dais found in DT

**现象**：`q6asm-dai ...: No dais found in DT`，probe 失败 `-22`。

**根因**：`q6asm_dai_probe()` 用 `of_get_child_count(dev->of_node)` 统计前端，节点下必须显式列出 `dai@N`。

**修复**：
```dts
&q6asmdai {
	dai@0 { reg = <MSM_FRONTEND_DAI_MULTIMEDIA1>; };
	dai@1 { reg = <MSM_FRONTEND_DAI_MULTIMEDIA2>; };
	dai@2 { reg = <MSM_FRONTEND_DAI_MULTIMEDIA3>; };
};
```

---

## 16. slimbam（BAM DMA）导致崩溃/卡启动

**现象**：
- `slimbam` 保持 disabled：`Failed to request RX dma channel` → `Message buffer unavailable` → `qcom_slim_ngd_xfer_msg` oops；
- 打开 `&slimbam { status = "okay"; }`：整机启动卡死。

**现状**：已在 `qcom-ngd-ctrl.c` 加防崩保护（ngd 未初始化直接 `-ENODEV`），但音频链路仍未通。

**下一步**：对照主线 `drivers/slimbus/qcom-ngd-ctrl.c` 重构 BAM/消息队列初始化；参考 hotdog（其音频也是 Partial）。

---

## 17. 触摸完全不存在

**现象**：`/sys/bus/i2c/devices/` 里没有任何触摸设备。

**根因**：触摸挂在 `qupv3_id_2`（`0xc80000`）下，而 DTS 只启用了 `qupv3_id_1`。

**修复**：
```dts
&qupv3_id_2 { status = "okay"; };
&gpi_dma2  { status = "okay"; };
```

---

## 18. 触摸轴参数缺失

**现象**：`s6sy761 0-0048: the axis have not been set`，触摸坐标不可用。

**根因**：缺少 `touchscreen-size-x/y`。

**修复**：`touchscreen-size-x = <1440>; touchscreen-size-y = <3120>;`（`inverted-y` 视方向需要）。

---

## 19. 休眠唤醒后触摸失效

**现象**：suspend → resume 后触摸无响应，`-ENODEV`。

**根因**：`avdd` 与 WCN3990 共用，息屏时掉电不足以让控制器重启；旧驱动在 resume 里固定 `msleep(140)` 后只读一次事件，极易失败。

**修复**（照抄 hotdog）：
- DTS 加 `reset-gpios = <&tlmm 54 GPIO_ACTIVE_LOW>;`
- 驱动：可选 reset-gpio + 复位脉冲 + 400ms 内轮询 boot-complete，最多 3 次

**文件**：`drivers/input/touchscreen/s6sy761.c`、板级 DTS

---

## 20. PowerShell 内联命令破坏引号

**现象**：`wsl bash -c "..."` 里带 `|`、`{}`、`$()` 时命令被 PowerShell 拆坏，出现 `grep: command not found` 之类。

**规则**：**所有复杂命令写成 `.sh` 脚本文件**，用 `wsl -u root -e bash /path/script.sh` 执行。

---

## 21. 镜像构建的 bootstrap/loop/磁盘坑

- **bootstrap 工具**：`mmdebstrap` 在 qemu 下会 `hooklistener` 失败；改用 `BOOTSTRAP_TOOL=debootstrap`；
- **loop 分区竞态**：`losetup -P` 后立刻 `mkfs.vfat /dev/loopNp1` 会 `No such file`；在脚本里加 `sleep 1; partprobe`；
- **挂载残留**：构建失败后 `rootdir` 仍挂着旧 loop，必须 `umount -R` + `losetup -d` 再重来；
- **磁盘空间**：C: 盘占用 8G 镜像容易满，先清理旧镜像；
- **权限**：`build.sh` 需 `chmod +x`。

---

## 22. GitHub 大包推送 500

**现象**：推送 2GB 内核分支：
```
remote: fatal: did not receive expected object ...
error: remote unpack failed: index-pack failed
error: RPC failed; HTTP 500
```

**根因**：大 pack 在链路上被中断（单快照 298MB 仍失败），代理也无法绕过。

**对策**：
1. `http.postBuffer=1G`、`http.version=HTTP/1.1`、`--no-thin`；
2. **分批提交 + 分批推送**（每个顶层目录一个提交，推临时分支 `kernel-src-parts`，最后一次性推正式分支）；
3. 代理：`http://127.0.0.1:31181`（`sslVerify=false`）只对 API/小请求稳定。

---

> 新增踩坑请按「现象 / 根因 / 修复 / 文件」四段式追加，并在目录里补一行。

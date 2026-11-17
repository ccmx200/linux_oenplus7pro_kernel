# U-Boot：构建、按键与启动

本机 U-Boot 源码位于 `/root/uboot`，分支 `op7p-keys`。

## 构建

```bash
# 一次性：生成板级 DTS + 应用按键增量 + 编译
bash wsl/147-ubuild.sh

# 打包成 Android bootimg（gzip u-boot-nodtb + 追加 dtb）
bash wsl/148-ubimg.sh
# 产物：nura-out/uboot-guacamole.img
```

刷入：

```bash
fastboot flash boot_a uboot-guacamole.img
fastboot erase misc
fastboot reboot
```

> 回滚镜像：`nura-out/uboot-guacamole-keys.img`（已验证可启动）。

## 启动方式

```ini
bootcmd=bootflow scan -b; pause; run menucmd
```

- `bootflow scan -b` 扫描块设备上的 EFI 程序（ESP 里的 systemd-boot），**不依赖 EFI 变量**；
- 失败才落到 `run menucmd`（启动菜单）。

## 音量键

| 操作 | 行为 |
|:--|:--|
| 按住 **音量上** 开机 | 进入 U-Boot 启动菜单 |
| 按住 **音量下** 开机 | 进入 fastboot |
| 不按 | 正常启动 Linux |

菜单内导航依赖 `button-kbd` 把按键事件映射成方向键（`CONFIG_BUTTON_KEYBOARD`）。

## 关键改动（相对上游）

| 文件 | 改动 |
|:--|:--|
| `drivers/gpio/qcom_spmi_gpio.c` | 支持 `qcom,pm8150-gpio(+b/l)`；probe 时强制打开引脚 6/7 输入缓冲 |
| `drivers/spmi/spmi-msm.c` | APID 通道按需查找（修 pid 0xc0–0xcf 缺失） |
| `drivers/button/button-gpio.c` | 无（调试打印已移除） |
| `drivers/video/video-uclass.c` | probe 后清屏 + 全刷新（避免花屏残留） |
| `board/qualcomm/qcom-phone.env` | `bootcmd`（bootflow）、`button_cmd`、静默控制台 |
| `dts/.../sm8150-oneplus-guacamole.dts` | 音量下键 + pinctrl + `power-source = <1>` |

## 调试（无串口时）

设备没有可用 UART，调试靠**屏幕**：

1. `bootcmd` 前加 `sleep 10~15` 让信息停留；
2. 用 `printf("TAG ...")` 打到 `vidconsole`；
3. 用 `button list` 强制 probe `button → gpio → pmic → spmi` 整条链（U-Boot 是懒加载，不访问就不 probe）；
4. 已知教训：`usbacm` 进默认 stdout 会卡启动；`usbgadget` 命令在该配置下不存在。

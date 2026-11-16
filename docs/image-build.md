# 镜像构建（Ubuntu GNOME + 中文 + USB NCM）

使用 `GengWei1997/linux-xiaomi-raphael-uboot` 的镜像构建器，但按一加 7 Pro 调整：

| 变量 | 值 |
|---|---|
| `SYSTEM_TYPE` | `ubuntu-gnome` |
| `KERNEL_VERSION` | `7.3` |
| `HOSTNAME` | `oneplus-guacamole` |
| `IMAGE_NAME` | `rootfs-op7p.img` |
| `IMAGE_SIZE` | `8G`（桌面版） |
| `IMAGE_UUID` | `ee8d3593-59b1-480e-a3b6-4fefb17ee7d8` |
| `KERNEL_DEBS_DIR` | `xiaomi-raphael-debs_7.3`（脚本内固定名，可改用软链） |

构建：

```bash
cd linux-xiaomi-raphael-uboot
UBUNTU_VERSION=resolute ./build.sh ubuntu-gnome 7.3 gnome
```

产物为 `rootfs.img`（GPT：p1 ESP 256M，p2 ext4 8G），刷入 `userdata` 后：

```bash
fastboot flash userdata rootfs.img
fastboot erase misc
fastboot reboot
```

镜像已内置：

- GNOME 桌面 + 中文语言包 + ibus 输入法（`scripts/07-config-locale.sh`）
- USB NCM 网络 172.16.42.1/24（`scripts/10-config-ncm.sh`）
- 内核模块：`panel-samsung-oneplus-dsc`、`s6sy761`、`ath10k_snoc`
- hwmon 温度阈值、DTS（面板/触摸/GPU/WiFi）

刷完后仍需放入设备专有固件（见 README「固件」一节）。

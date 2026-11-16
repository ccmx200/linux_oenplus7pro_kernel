#!/bin/bash
set -uo pipefail
C=/mnt/c/Users/cuicanmx/Documents/deepseek-harness/default-workspace/oneplus7pro
cat >> "$C/STATUS.md" <<'EOF'

## 2026-11-17 WiFi 打通（wlan0 + 扫描成功）

**结论：一加 7 Pro mainline WiFi 可用。** 关键组合：

1. **ath10k 驱动补丁**（来自 `Sr-0w/hotdog-linux-bringup` 的 `0156` 补丁里 ath10k 部分，已打在 raphael-v7.3.0 树上）：
   - `ath10k_qmi_wlan_enable()` 处理 `QMI_ERR_INCOMPATIBLE_STATE_V01`：先 `wlan_disable()` 再重试 config（解决 `config request rejected: 90`）；
   - `ath10k_qmi_reclaim_msa()`：modem 崩溃后回收 MSA 区域；
   - `device_init_wakeup()`（suspend 保持链路）。
   - 补丁文件：`nura-out/ath10k-hotdog-fixes.patch`，模块：`nura-out/ath10k_{core,snoc}-fixed.ko`。
2. **固件用 hotdog 的 WCN3990 套件**（guac 原厂 OOS11 的 `WLAN.HL.3.2.0` 会在 modem `wlan_process` 里 assert）：
   - `wlanmdsp.mbn` = hotdog 版 `WLAN.HL.3.0.c8-00232`（3.9M）→ `/lib/firmware/qcom/sm8150/oneplus7/wlanmdsp.mbn`
   - `board-2.bin`（876K）、`firmware-5.bin`（60B）→ `/lib/firmware/ath10k/WCN3990/hw1.0/`
3. **DTB**：`nura-out/sm8150-guac-wifi-work.dtb`
   - `&wifi { status = "okay"; vdd-0.8-cx-mx=l1a; vdd-1.8-xo=l7a; vdd-1.3-rfa=l2c; vdd-3.3-ch0=l11c; vdd-3.3-ch1=l10c; }`
   - `&remoteproc_mpss { firmware-name = "qcom/sm8150/oneplus7/modem.mdt"; status = "okay"; }`
   - 无 quirk、无 no-msa、wifi 不接 pwrseq。
4. modem 固件用 **guac 自己的 NON-HLOS**（hotdog 的 modem.mbn 在 guac 上 offline，设备签名不同）。
5. 结果：`wlan0` 自动加载、`nmcli` 扫描到 14+ 个 2.4G/5G 网络，无 `wlan_process` 崩溃；sforshee 校准/board-2 均为 hotdog 套件。
6. 注意：`wlan0` 显示 `NO-CARRIER` 属正常（未关联 AP）；assoc 需要目标 AP 密码。
EOF
echo "status updated"

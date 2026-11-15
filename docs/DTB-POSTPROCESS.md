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

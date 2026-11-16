#!/bin/bash
set -uo pipefail
K=/root/kbuild/linux
D=$K/arch/arm64/boot/dts/qcom
C=/mnt/c/Users/cuicanmx/Documents/deepseek-harness/default-workspace/oneplus7pro/dts

python3 - "$C/sm8150-oneplus-guacamole.dts" <<'PY'
import sys, re
p=sys.argv[1]; s=open(p).read()
if "oneplus-dsc" in s:
    print("already has panel"); raise SystemExit
s = s.rstrip() + """

/* ---------- 原生 DSI + Samsung OnePlus DSC 面板 ---------- */

/ {
	panel_avdd_1p8: panel-avdd-regulator {
		compatible = "regulator-fixed";
		regulator-name = "panel_avdd_1p8";
		regulator-min-microvolt = <1800000>;
		regulator-max-microvolt = <1800000>;
		regulator-always-on;
		regulator-boot-on;
	};
};

&tlmm {
	panel_te_default: panel-te-default-state {
		pins = "gpio8";
		function = "mdp_vsync";
		drive-strength = <2>;
		bias-pull-down;
	};
};

&mdss {
	status = "okay";
};

&mdss_dsi0_phy {
	status = "okay";
};

&mdss_dsi0 {
	status = "okay";

	panel@0 {
		compatible = "samsung,oneplus-dsc";
		reg = <0>;

		vddio-supply = <&vreg_l14a_1p8>;
		avdd-supply = <&panel_avdd_1p8>;

		reset-gpios = <&tlmm 6 GPIO_ACTIVE_LOW>;
		pinctrl-0 = <&panel_te_default>;
		pinctrl-names = "default";

		port {
			panel_in: endpoint {
				remote-endpoint = <&mdss_dsi0_out>;
			};
		};
	};
};

&mdss_dsi0_out {
	data-lanes = <0 1 2 3>;
	remote-endpoint = <&panel_in>;
	status = "okay";
};
"""
open(p,"w").write(s)
print("panel + mdss/dsi added")
PY

cp -f "$C/sm8150-oneplus-guacamole.dts" "$D/"
cd "$K"
rm -f "$D/sm8150-oneplus-guacamole.dtb"
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- qcom/sm8150-oneplus-guacamole.dtb 2>&1 | tail -6
ls -lh "$D/sm8150-oneplus-guacamole.dtb" 2>/dev/null || exit 1
cp -f "$D/sm8150-oneplus-guacamole.dtb" /root/panel.dtb

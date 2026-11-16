#!/bin/bash
set -uo pipefail
C=/mnt/c/Users/cuicanmx/Documents/deepseek-harness/default-workspace/oneplus7pro/dts
cp -f "$C/sm8150-oneplus-guacamole.dts" /root/guac-dts-before-clean.dts
python3 - "$C/sm8150-oneplus-guacamole.dts" <<'PY'
import sys, re
p=sys.argv[1]; s=open(p).read()
labels = ["mdss_dsi0_out", "mdss_dsi0_phy", "mdss_dsi0", "mdss_mdp", "mdss"]
def strip_block(s, label):
    n = 0
    while True:
        m = re.search(r"&" + label + r"\s*\{", s)
        if not m: break
        start = m.start()
        j = s.find("{", m.start()); depth = 0; k = j
        while k < len(s):
            if s[k] == "{": depth += 1
            elif s[k] == "}":
                depth -= 1
                if depth == 0: break
            k += 1
        # 吞掉结尾的 ';'
        end = k + 1
        while end < len(s) and s[end] in " \t\n;":
            end += 1
        s = s[:start] + s[end:]
        n += 1
    return s, n

total = 0
for lab in labels:
    s, n = strip_block(s, lab); total += n
print("removed blocks:", total)

# 去掉旧的 panel@0（ams639 残留）——它在 dsi0 块内已被删除；再保险清一次
s = re.sub(r"panel@0\s*\{.*?\n\t\};\n", "", s, flags=re.S, count=1)

# 追加规范块
s = s.rstrip() + """

/* ================= 显示（原生 DSI + OnePlus DSC 面板） ================= */

&mdss {
	status = "okay";
};

&mdss_mdp {
	status = "okay";
};

&mdss_dsi0_phy {
	status = "okay";
	vdds-supply = <&vreg_l5a_0p875>;
};

&mdss_dsi0 {
	status = "okay";
	vdda-supply = <&vreg_l3c_1p2>;

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
print("cleaned + canonical display block appended")
PY
echo "=== 剩余 mdss 引用"
grep -n -e '&mdss' -e 'panel@0' "$C/sm8150-oneplus-guacamole.dts" | head -20

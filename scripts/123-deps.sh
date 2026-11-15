#!/bin/bash
set -u
export DEBIAN_FRONTEND=noninteractive
apt-get install -y -qq kpartx parted dosfstools android-sdk-libsparse-utils android-tools-mkbootimg 2>&1 | tail -6
echo "---"
for t in kpartx mkbootimg simg2img debugfs parted; do
    printf '%-12s %s\n' "$t" "$(command -v "$t" || echo MISSING)"
done

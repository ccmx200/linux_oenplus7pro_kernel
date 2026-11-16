#!/bin/bash
set -u
F=/root/hotdog/aports/device/testing/firmware-oneplus-hotdog/APKBUILD
awk '/^wlan\(\)/{p=1} p{print} p&&/^}/{exit}' "$F"

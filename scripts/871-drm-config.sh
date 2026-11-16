#!/bin/bash
set -u
cd /root/kbuild/linux
grep -E '^CONFIG_DRM=|^CONFIG_DRM_MSM=|^CONFIG_DRM_MSM_DSI|^CONFIG_DRM_PANEL_SAMSUNG_ONEPLUS|^CONFIG_DRM_PANEL=' .config
ls -lh drivers/gpu/drm/msm/msm.ko 2>/dev/null

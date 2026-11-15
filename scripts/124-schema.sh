#!/bin/bash
set -u
P=/root/.local/var/pmbootstrap/cache_git/pmaports
URL=https://gitlab.nura.eco/nura/pmaports/-/raw/main/deviceinfo_schema.toml
if curl -fsSL --max-time 240 -o "$P/deviceinfo_schema.toml" "$URL"; then
    echo "OK $(wc -c < "$P/deviceinfo_schema.toml") bytes"
    head -20 "$P/deviceinfo_schema.toml"
else
    echo FAILED
fi

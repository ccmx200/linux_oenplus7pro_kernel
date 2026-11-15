#!/bin/bash
set -u
echo "=== full help grep arch"
mmdebstrap --help 2>&1 | grep -inE 'architect|native|aarch|foreign|dpkg --print' | head -20
echo
echo "=== try --arch=arm64 (dry, cite only)"
mmdebstrap --arch=arm64 --variant=minbase --help >/dev/null 2>&1; echo "arch= exit=$?"
echo
echo "=== try --architecture=arm64"
mmdebstrap --architecture=arm64 --variant=minbase --help >/dev/null 2>&1; echo "architecture= exit=$?"
echo
echo "=== mmdebstrap version"
mmdebstrap --version 2>&1 | head -3
echo
echo "=== dpkg arch"
dpkg --print-architecture

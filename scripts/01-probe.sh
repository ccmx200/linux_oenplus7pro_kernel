#!/bin/bash
set -u
echo "=== mmdebstrap arch option"
mmdebstrap --help 2>&1 | grep -iE 'arch|dpkg|aptopt' | head -12
echo
echo "=== mkbootimg"
mkbootimg --help 2>&1 | head -30 || true
echo
echo "=== mkbootimg version"
mkbootimg --version 2>&1 || true

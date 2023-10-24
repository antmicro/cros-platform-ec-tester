#!/usr/bin/env bash
set -x

# Setup git
git config --global user.name "Antmicro"
git config --global user.email "contact@antmicro.com"

# Install depot_tools
git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git &> /dev/null
export PATH="${PWD}/depot_tools:${PATH}"

mkdir -p ~/chromiumos
cd ~/chromiumos

# Get the source
# repo init cannot be silent as it prompts us for input
repo init -u https://chromium.googlesource.com/chromiumos/manifest -b main
repo sync -j4 &> /dev/null

cd ~/chromiumos/src

cros_sdk --download
cros_sdk -- bash -c "sudo cros_setup_toolchains &> /dev/null" &> /dev/null

# Build examples
cros_sdk -- bash -c "cd ../platform/ec; make tests BOARD=dartmonkey -j 4"
cros_sdk -- bash -c "cd ../platform/ec; make tests BOARD=bloonchipper -j 4"
cros_sdk -- bash -c "cd ../platform/ec; make tests BOARD=helipilot -j 4"

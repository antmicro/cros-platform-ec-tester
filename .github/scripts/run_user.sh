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

# This directory is sometimes created is such a way that it is owned
# by root instead of the 'runner' user. During test building some compilers (eg. Go, ccache)
# will try to cache compilation result in this directory, but will not be able
# to do so as the test building is performed as a regular user (the cros_sdk 
# program cannot be started from as root). Solution is to remove that directory
# so it can be recreated and accessed during test building from as a normal user 
cros_sdk -- bash -c "sudo rm -rf ~/.cache"

# Build examples
cros_sdk -- bash -c "cd ../platform/ec; make tests BOARD=dartmonkey -j 4"
cros_sdk -- bash -c "cd ../platform/ec; make tests BOARD=bloonchipper -j 4"
cros_sdk -- bash -c "cd ../platform/ec; make tests BOARD=helipilot -j 4"

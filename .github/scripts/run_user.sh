#!/usr/bin/env bash
set -x

# Setup git
git config --global user.name "Antmicro"
git config --global user.email "contact@antmicro.com"

# Install depot_tools
git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
export PATH="${PWD}/depot_tools:${PATH}"

mkdir -p ~/chromiumos
cd ~/chromiumos

# Get the source
repo init -u https://chromium.googlesource.com/chromiumos/manifest.git
repo sync -j 4

# Currently helipilot contains two smt32 specific tests (cortexm_fpu, stm32f_rtc)
# on it's test list, that will not build for helipilot. The following patch removes them
cd ~/chromiumos/src/platform/ec
git apply ~/helipilot_build.patch

cd ~/chromiumos/src

cros_sdk --download

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
cros_sdk -- bash -c "cd ../platform/ec; zmake -j 4 build rex skyrim"

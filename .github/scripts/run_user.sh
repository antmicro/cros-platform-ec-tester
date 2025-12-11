#!/usr/bin/env bash
set -xeu

# Setup git
git config --global user.name "Antmicro"
git config --global user.email "contact@antmicro.com"

# Install depot_tools
git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
export PATH="${PWD}/depot_tools:${PATH}"

mkdir -p ~/chromiumos
cd ~/chromiumos

# Clone sources, pinned to a working SHA.
repo init -b "c2b4b1de4e50aaae99207ef3f21a6baa38e36ec9" -u https://chromium.googlesource.com/chromiumos/manifest.git
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

# Freeze revisions so that Sanok topic CLs will apply cleanly
cd ~/chromiumos/src/platform/ec
git fetch https://chromium.googlesource.com/chromiumos/platform/ec 035fdda8c0180c9953371070985704414430042b && git checkout FETCH_HEAD
cd ~/chromiumos/src/third_party/zephyr/main
git fetch https://chromium.googlesource.com/chromiumos/third_party/zephyr ee9db7a2fa17c2a89542f64a2a54efafee9e842d && git checkout FETCH_HEAD

# Cherry-pick necessary Sanok EC commit
cd ~/chromiumos/src/platform/ec
git fetch https://chromium.googlesource.com/chromiumos/platform/ec refs/changes/60/6597060/57 && git cherry-pick FETCH_HEAD

# Apply Sanok patch
git apply ~/sanok_build.patch

# Clone Egis repos
cd ~/chromiumos/src/third_party/zephyr
git clone https://github.com/EgisMCU/hal_egis.git
git clone https://github.com/EgisMCU/egis_module.git

cd ~/chromiumos/src

# Build Sanok samples
cros_sdk -- bash -c "zmake -l DEBUG build sanok --clobber"

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
repo init -b "dc3f359384c44a7463dd1e5c4d81ca5affac3073" -u https://chromium.googlesource.com/chromiumos/manifest.git
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
git fetch https://chromium.googlesource.com/chromiumos/platform/ec 62cd531c244a9c36e2a197bc1ae539414ec188e1 && git checkout FETCH_HEAD
cd ~/chromiumos/src/third_party/zephyr/main
git fetch https://chromium.googlesource.com/chromiumos/third_party/zephyr eec31b1bc0da7f5d3df4e1c71faf3721f7670d92 && git checkout FETCH_HEAD

# Cherry-pick necessary Sanok EC commits
cd ~/chromiumos/src/platform/ec
git fetch https://chromium.googlesource.com/chromiumos/platform/ec refs/changes/60/6597060/34 && git cherry-pick FETCH_HEAD
git fetch https://chromium.googlesource.com/chromiumos/platform/ec refs/changes/58/6597058/33 && git cherry-pick FETCH_HEAD

# Apply Sanok KConfig patch
git apply ~/sanok_build.patch

# Cherry-pick necessary Zephyr commits
cd ~/chromiumos/src/third_party/zephyr/main
git fetch https://chromium.googlesource.com/chromiumos/third_party/zephyr refs/changes/13/7086413/2 && git cherry-pick FETCH_HEAD
git fetch https://chromium.googlesource.com/chromiumos/third_party/zephyr refs/changes/11/7086411/2 && git cherry-pick FETCH_HEAD
git fetch https://chromium.googlesource.com/chromiumos/third_party/zephyr refs/changes/10/7086410/2 && git cherry-pick FETCH_HEAD
git fetch https://chromium.googlesource.com/chromiumos/third_party/zephyr refs/changes/09/7086409/2 && git cherry-pick FETCH_HEAD
git fetch https://chromium.googlesource.com/chromiumos/third_party/zephyr refs/changes/08/7086408/2 && git cherry-pick FETCH_HEAD

# Clone Egis repos
cd ~/chromiumos/src/third_party/zephyr
git clone https://github.com/EgisMCU/hal_egis.git
git clone https://github.com/EgisMCU/egis_module.git

cd ~/chromiumos/src

# Build Sanok samples
cros_sdk -- bash -c "zmake -l DEBUG build sanok --clobber"

#!/usr/bin/env bash
set -x # print all commands to the terminal
set -o errexit  # abort on nonzero exitstatus
set -o nounset  # abort on unbound variable
set -o pipefail # don't hide errors within pipes

if [ "$#" -lt 5 ]; then
  echo "usage: $0 <cros_manifest_ref> <ec_rev> <zephyr_rev> <ec_changelist_rev> <depot_tools_rev>" >&2
  exit 1
fi

cros_manifest_ref="$1"
ec_rev="$2"
zephyr_rev="$3"
ec_changelist_rev="$4"
depot_tools_rev="$5"

# Setup git
git config --global user.name "Antmicro"
git config --global user.email "contact@antmicro.com"

# Install depot_tools
git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
cd depot_tools
git checkout "$depot_tools_rev"
cd ..
export PATH="${PWD}/depot_tools:${PATH}"

mkdir -p ~/chromiumos
cd ~/chromiumos

# Clone sources, pinned to a working manifest ref.
repo init --depth=1 --manifest-branch "$cros_manifest_ref" --manifest-url https://chromium.googlesource.com/chromiumos/manifest.git
# Remove the full linux kernel clones, because we don't need them for the EC and they're the main bottleneck.
sed -i '/^[[:space:]]*<include name="_kernel_upstream\.xml"[[:space:]]*\/>[[:space:]]*$/d' .repo/manifests/default.xml
sed -i '/<project[^>]*name="chromiumos\/third_party\/kernel"/,/<\/project>/d' .repo/manifests/default.xml
# To speed up syncing, first use 4 cores to fetch (recommended number)
# and then use all available cores to update the working tree.
repo sync --fail-fast --network-only --jobs 4
repo sync --fail-fast --local-only --jobs $(nproc)

# Freeze revisions so that Sanok topic CLs will apply cleanly
cd ~/chromiumos/src/platform/ec
git fetch https://chromium.googlesource.com/chromiumos/platform/ec "$ec_rev" && git checkout FETCH_HEAD
cd ~/chromiumos/src/third_party/zephyr/main
git fetch https://chromium.googlesource.com/chromiumos/third_party/zephyr "$zephyr_rev" && git checkout FETCH_HEAD

# Cherry-pick necessary Sanok EC commit
cd ~/chromiumos/src/platform/ec
git fetch https://chromium.googlesource.com/chromiumos/platform/ec "$ec_changelist_rev" && git cherry-pick FETCH_HEAD

# Apply Sanok patch
git apply ~/sanok_build.patch
# Apply test runner patch (so we can fetch the current test list easily)
git apply ~/test_runner.patch

# Install cros_sdk after checking out the correct SHA, so it downloads the correct version
# (based on src/third_party/chromiumos-overlay/chromeos/binhost/host/sdk_version.conf).
cd ~/chromiumos/src
cros_sdk --download

# This directory is sometimes created is such a way that it is owned
# by root instead of the 'runner' user. During test building some compilers (eg. Go, ccache)
# will try to cache compilation result in this directory, but will not be able
# to do so as the test building is performed as a regular user (the cros_sdk
# program cannot be started from as root). Solution is to remove that directory
# so it can be recreated and accessed during test building from as a normal user
cros_sdk -- bash -c "sudo rm -rf ~/.cache"

cd ~/chromiumos/src

# Build Sanok samples
cros_sdk -- bash -c "zmake -l DEBUG build sanok --clobber"

# Use the test runner to get the test list
test_runner_output="$(
  cros_sdk -- bash -c 'cd ../platform/ec && ./test/run_device_tests.py --board sanok --zephyr --exit_after_printing_tests' 2>&1
)"
# Extract the list from the captured output.
test_list="$(
  printf '%s\n' "$test_runner_output" |
    sed -n "s/^DEBUG:Running tests: //p" # Capture only the relevant line, and strip its prefix.
)"

# Build all the listed test binaries
cd ~/chromiumos/src/platform/ec
test_bins_dir=/home/runner/sanok-test-bins
mkdir -p "$test_bins_dir"
~/build_tests.sh "${test_list}" "${test_bins_dir}"

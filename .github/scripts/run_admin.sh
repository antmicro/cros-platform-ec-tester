#!/usr/bin/env bash
set -x

if [ "$#" -lt 5 ]; then
  echo "usage: $0 <cros_manifest_ref> <ec_rev> <zephyr_rev> <ec_changelist_rev> <depot_tools_rev>" >&2
  exit 1
fi

cros_manifest_ref="$1"
ec_rev="$2"
zephyr_rev="$3"
ec_changelist_rev="$4"
depot_tools_rev="$5"

export DEBIAN_FRONTEND=noninteractive

apt update && apt upgrade --no-install-recommends -yqq &>/dev/null
apt install --no-install-recommends -yqq git curl xz-utils python3-pkg-resources python3-virtualenv python3-oauth2client openssh-client zstd &>/dev/null

useradd -m runner
usermod -aG sudo runner

echo 'runner ALL=(ALL:ALL) NOPASSWD: ALL' >/etc/sudoers.d/runner

cp -v run_user.sh test_runner.patch sanok_build.patch build_tests.sh /home/runner
cd /home/runner || exit

chown runner run_user.sh test_runner.patch sanok_build.patch build_tests.sh
chmod +x run_user.sh build_tests.sh

sudo -u runner ./run_user.sh \
  "$cros_manifest_ref" \
  "$ec_rev" \
  "$zephyr_rev" \
  "$ec_changelist_rev" \
  "$depot_tools_rev" |
  tee /root/vm_log.txt

shutdown -h now

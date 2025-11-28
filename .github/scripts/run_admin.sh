#!/usr/bin/env bash
set -x

export DEBIAN_FRONTEND=noninteractive

apt update && apt upgrade --no-install-recommends -yqq &> /dev/null
apt install --no-install-recommends -yqq git curl xz-utils python3-pkg-resources python3-virtualenv python3-oauth2client openssh-client zstd &> /dev/null

useradd -m runner
usermod -aG sudo runner

echo 'runner ALL=(ALL:ALL) NOPASSWD: ALL' > /etc/sudoers.d/runner

cp -v run_user.sh sanok_build.patch helipilot_build.patch /home/runner
cd /home/runner

chown runner run_user.sh sanok_build.patch helipilot_build.patch
chmod +x run_user.sh

sudo -u runner ./run_user.sh | tee /root/vm_log.txt

shutdown -h now

#!/usr/bin/env bash
set -x

export DEBIAN_FRONTEND=noninteractive

apt update && apt upgrade --no-install-recommends -yqq &> /dev/null
apt install --no-install-recommends -yqq git curl xz-utils python3-pkg-resources python3-virtualenv python3-oauth2client &> /dev/null

useradd -m runner
usermod -aG sudo runner

echo 'runner ALL=(ALL:ALL) NOPASSWD: ALL' > /etc/sudoers.d/runner

cp run_user.sh helipilot_build.patch /home/runner
cd /home/runner

chown runner run_user.sh helipilot_build.patch
chmod +x run_user.sh

sudo -u runner ./run_user.sh

shutdown -h now

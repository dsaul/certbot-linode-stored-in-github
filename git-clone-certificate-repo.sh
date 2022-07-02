#!/usr/bin/env bash
set -o errexit
set -o nounset
#set -o xtrace
set -o pipefail

ssh-add /root/.ssh/KEYPAIR_PRIVATE; git clone --depth 1 $GIT_URL -b master /etc/letsencrypt
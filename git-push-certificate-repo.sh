#!/usr/bin/env bash
set -o errexit
set -o nounset
#set -o xtrace
set -o pipefail

ssh-add /root/.ssh/KEYPAIR_PRIVATE; git push origin master || echo "git was unable to push"
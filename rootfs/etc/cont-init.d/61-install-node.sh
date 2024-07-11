#!/bin/bash

set -e # Exit immediately if a command exits with a non-zero status.
set -u # Treat unset variables as an error.

log() {
    echo "[cont-init.d] $(basename $0): $*"
}

if [ ${ENABLE_NODE} -eq 0 ] || [ -n "$(which node)" ]; then
  exit 0
fi

if [ ! -f "${PKG_PATH}/node-v${NODE_VERSION}-linux-x64.tar.gz" ]; then
  # ${NODE_VERSION%%.*} -> 16.19.1 -> 16
  wget https://registry.npmmirror.com/-/binary/node/latest-v${NODE_VERSION%%.*}.x/node-v${NODE_VERSION}-linux-x64.tar.gz -O ${PKG_PATH}/node-v${NODE_VERSION}-linux-x64.tar.gz
fi

tar -C /usr/local --strip-components 1 -xzf ${PKG_PATH}/node-v${NODE_VERSION}-linux-x64.tar.gz

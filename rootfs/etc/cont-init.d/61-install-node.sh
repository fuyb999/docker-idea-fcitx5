#!/bin/bash

set -e # Exit immediately if a command exits with a non-zero status.
set -u # Treat unset variables as an error.

log() {
    echo "[cont-init.d] $(basename $0): $*"
}

export NODE_PATH=${XDG_SOFTWARE_HOME}/node-v${NODE_VERSION}

install(){
  rm -rf /usr/local/bin/node
  ln -s $NODE_PATH/bin/node /usr/local/bin/node
}

if [ ${ENABLE_NODE} -eq 0 ] || [ -n "$(which node)" ]; then
  install
  exit 0
fi

if [ ! -f "${PKG_HOME}/node-v${NODE_VERSION}-linux-x64.tar.gz" ]; then
  # ${NODE_VERSION%%.*} -> 16.19.1 -> 16
  wget https://registry.npmmirror.com/-/binary/node/latest-v${NODE_VERSION%%.*}.x/node-v${NODE_VERSION}-linux-x64.tar.gz -O ${PKG_HOME}/node-v${NODE_VERSION}-linux-x64.tar.gz
fi

mkdir -p $NODE_PATH
tar -C $NODE_PATH --strip-components 1 -xzf ${PKG_HOME}/node-v${NODE_VERSION}-linux-x64.tar.gz

install
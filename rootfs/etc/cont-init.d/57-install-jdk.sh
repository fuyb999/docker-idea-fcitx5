#!/bin/sh

set -e # Exit immediately if a command exits with a non-zero status.
set -u # Treat unset variables as an error.

log() {
    echo "[cont-init.d] $(basename $0): $*"
}

export PKG_PATH=/config/packages

if [ ! -d "$PKG_PATH" ]; then
  mkdir -p ${PKG_PATH}
fi

export JAVA_HOME=$XDG_CONFIG_HOME/jdk-${JDK_VERSION}
export PATH=$JAVA_HOME/bin:$PATH

if [ -d "${JAVA_HOME}" ]; then
  exit 0
fi

if [ ! -f "${PKG_PATH}/jdk-${JDK_VERSION}_linux-x64_bin.tar.gz" ]; then
  wget https://download.oracle.com/java/17/archive/jdk-${JDK_VERSION}_linux-x64_bin.tar.gz -O ${PKG_PATH}/jdk-${JDK_VERSION}_linux-x64_bin.tar.gz
fi

tar -xzf ${PKG_PATH}/jdk-${JDK_VERSION}_linux-x64_bin.tar.gz -C $XDG_CONFIG_HOME
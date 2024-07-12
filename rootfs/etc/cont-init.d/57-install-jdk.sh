#!/bin/bash

set -e # Exit immediately if a command exits with a non-zero status.
set -u # Treat unset variables as an error.

log() {
    echo "[cont-init.d] $(basename $0): $*"
}

if [ ! -d "$PKG_HOME" ]; then
  mkdir -p ${PKG_HOME}
fi

export JDK_HOME=${XDG_SOFTWARE_HOME}/jdk-${JDK_VERSION}

install(){
  rm -rf $JAVA_HOME
  ln -s $JDK_HOME $JAVA_HOME
}

if [ ${ENABLE_JDK} -eq 0 ] || [ -n "$(which java)" ]; then
  install
  exit 0
fi

if [ ! -f "${PKG_HOME}/jdk-${JDK_VERSION}_linux-x64_bin.tar.gz" ]; then
  wget https://download.oracle.com/java/17/archive/jdk-${JDK_VERSION}_linux-x64_bin.tar.gz -O ${PKG_HOME}/jdk-${JDK_VERSION}_linux-x64_bin.tar.gz
fi

mkdir -p $JDK_HOME
tar --strip-components=1 -xzf ${PKG_HOME}/jdk-${JDK_VERSION}_linux-x64_bin.tar.gz -C $JDK_HOME

install
#!/bin/bash

set -e # Exit immediately if a command exits with a non-zero status.
set -u # Treat unset variables as an error.

log() {
    echo "[cont-init.d] $(basename $0): $*"
}

#HOME=/config

if [ -z "$(grep messagebus /etc/group)" ]; then
  sudo addgroup messagebus
fi

if [ -z "$(grep plocate /etc/group)" ]; then
  sudo addgroup plocate
fi

if [ ! -d "$PKG_HOME" ]; then
  mkdir -p ${PKG_HOME}
fi

if [ ${ENABLE_JDK} -eq 0 ]; then
 exit 0
fi

# 在 ENV 中定义的PATH 在此不生效
if [ ! -f $HOME/.bashrc ] || [ -z "$(cat $HOME/.bashrc | grep 'JAVA_HOME')" ]; then
  echo "export PATH=\$JAVA_HOME/bin:\$PATH" >> $HOME/.bashrc
fi

# 注意$HOME=/config 而不是 /root
source $HOME/.bashrc
if [ -n "$(which java)" ]; then
  exit 0
fi

if [ ! -f "${PKG_HOME}/jdk-${JDK_VERSION}_linux-x64_bin.tar.gz" ]; then
  wget https://download.oracle.com/java/17/archive/jdk-${JDK_VERSION}_linux-x64_bin.tar.gz -O ${PKG_HOME}/jdk-${JDK_VERSION}_linux-x64_bin.tar.gz
fi

mkdir -p $JAVA_HOME
tar --strip-components=1 -zxf ${PKG_HOME}/jdk-${JDK_VERSION}_linux-x64_bin.tar.gz -C $JAVA_HOME

#!/bin/sh

set -e # Exit immediately if a command exits with a non-zero status.
set -u # Treat unset variables as an error.

log() {
    echo "[cont-init.d] $(basename $0): $*"
}

export FIREFOX_PATH=${XDG_SOFTWARE_HOME}/firefox-${FIREFOX_VERSION}

install(){
  if [ -f "$FIREFOX_PATH/firefox" ]; then
    ln -sf $FIREFOX_PATH/firefox /usr/local/bin/firefox
  fi
}

install
if [ ${ENABLE_FIREFOX} -eq 0 ] || [ -n "$(which firefox)" ]; then
  exit 0
fi

if [ ! -f "${PKG_HOME}/firefox-${FIREFOX_VERSION}.tar.bz2" ]; then
  wget https://ftp.mozilla.org/pub/firefox/releases/${FIREFOX_VERSION}/linux-x86_64/zh-CN/firefox-${FIREFOX_VERSION}.tar.bz2 -O ${PKG_HOME}/firefox-${FIREFOX_VERSION}.tar.bz2
fi

mkdir -p $FIREFOX_PATH
tar -C $FIREFOX_PATH --strip-components=1 -jxf ${PKG_HOME}/firefox-${FIREFOX_VERSION}.tar.bz2

install

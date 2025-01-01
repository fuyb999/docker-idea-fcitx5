#!/bin/sh

set -e # Exit immediately if a command exits with a non-zero status.

log() {
    echo "[cont-init.d] $(basename $0): $*"
}

#HOME=/config

XDG_CACHE_HOME=/config/xdg/config
LOG_PATH=$HOME/log/idea
JREBEL_SERVER_HOME=${XDG_SOFTWARE_HOME}/jrebel-license-server
JA_NETFILTER_PATH=${XDG_SOFTWARE_HOME}/ja-netfilter-all

# Make sure mandatory directories exist.
if [ ! -d "$LOG_PATH" ]; then
  mkdir -p $LOG_PATH
fi

# Take ownership of the config directory content.
# /etc/cont-init.d/85-take-config-ownership.sh
#chown -R $USER_ID:$GROUP_ID /config/*
sudo chown $USER_ID:$GROUP_ID $WORKSPACES

if [ -d "$XDG_CACHE_HOME/JetBrains" ]; then
  find $XDG_CACHE_HOME/JetBrains -name '*.lock' | xargs rm -f
fi

# Install ja-netfilter
if [ -f "$PKG_HOME/crack/ja-netfilter-all.zip" ] && [ ! -d $JA_NETFILTER_PATH ] ; then
  unzip -oq $PKG_HOME/crack/ja-netfilter-all.zip -d $JA_NETFILTER_PATH
fi

if [ ! -d $JREBEL_SERVER_HOME ]; then
  mkdir -p $JREBEL_SERVER_HOME
fi

# Install jrebel-license-server
if [ -f "$PKG_HOME/crack/jrebel/jrebel-license-server-0.0.1.jar" ] && [ ! -f $JREBEL_SERVER_HOME/jrebel-license-server.jar ] ; then
  cp $PKG_HOME/crack/jrebel/jrebel-license-server-*.jar $JREBEL_SERVER_HOME/jrebel-license-server.jar
fi

# Maximize only the main/initial window.
#sed-patch 's/<application  type="normal">/<application type="normal" title="other">/' \
#        /run/openbox/rc.xml

# Take ownership of the output directory.
#if ! chown $USER_ID:$GROUP_ID /output; then
    # Failed to take ownership of /output.  This could happen when,
    # for example, the folder is mapped to a network share.
    # Continue if we have write permission, else fail.
#    if s6-setuidgid $USER_ID:$GROUP_ID [ ! -w /output ]; then
#        log "ERROR: Failed to take ownership and no write permission on /output."
#        exit 1
#    fi
#fi

# vim: set ft=sh :

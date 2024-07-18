#!/bin/sh

set -e # Exit immediately if a command exits with a non-zero status.
set -u # Treat unset variables as an error.

log() {
    echo "[cont-init.d] $(basename $0): $*"
}

HOME=/config

# Make sure mandatory directories exist.
if [ ! -d "$HOME/log/idea" ]; then
  mkdir -p $HOME/log/idea
fi

# Take ownership of the config directory content.
# /etc/cont-init.d/85-take-config-ownership.sh
chown -R $USER_ID:$GROUP_ID /config/*

if [ -d "$XDG_CACHE_HOME/JetBrains" ]; then
  chmod 777 -R $XDG_CACHE_HOME/JetBrains
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

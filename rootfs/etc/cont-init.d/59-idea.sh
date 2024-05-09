#!/bin/sh

set -e # Exit immediately if a command exits with a non-zero status.
set -u # Treat unset variables as an error.

log() {
    echo "[cont-init.d] $(basename $0): $*"
}

# Make sure mandatory directories exist.
mkdir -p /config/log/idea

# Take ownership of the config directory content.
chown -R $USER_ID:$GROUP_ID /config/*
chmod +x -R /config/xdg/cache/JetBrains

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

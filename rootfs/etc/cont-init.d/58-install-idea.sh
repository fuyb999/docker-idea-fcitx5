#!/bin/sh

set -e # Exit immediately if a command exits with a non-zero status.
set -u # Treat unset variables as an error.

log() {
    echo "[cont-init.d] $(basename $0): $*"
}

export IDEA_HOME=${XDG_SOFTWARE_HOME}/ideaIU-${IDEA_VERSION}

if [ -n "$(which $IDEA_HOME/bin/idea.sh)" ]; then
  exit 0
fi

# IDEA_BIN_ROOT_NAME="$(tar -tf /ideaIU-${IDEA_VERSION}.tar.gz | awk -F "/" '{print $1}' | sed -n '1p')"
if [ ! -f "${PKG_HOME}/ideaIU-${IDEA_VERSION}.tar.gz" ]; then
  wget https://download.jetbrains.com/idea/ideaIU-${IDEA_VERSION}.tar.gz -O ${PKG_HOME}/ideaIU-${IDEA_VERSION}.tar.gz
fi

mkdir -p $IDEA_HOME && \
  tar -xzf ${PKG_HOME}/ideaIU-${IDEA_VERSION}.tar.gz --strip-components=1 -C $IDEA_HOME && \
  echo "-javaagent:${XDG_SOFTWARE_HOME}/ja-netfilter-all/ja-netfilter.jar=jetbrains" >> $IDEA_HOME/bin/idea64.vmoptions && \
  echo "--add-opens=java.base/jdk.internal.org.objectweb.asm=ALL-UNNAMED" >> $IDEA_HOME/bin/idea64.vmoptions && \
  echo "--add-opens=java.base/jdk.internal.org.objectweb.asm.tree=ALL-UNNAMED" >> $IDEA_HOME/bin/idea64.vmoptions

# fix Error relocating /usr/local/idea/jbr/lib/libjli.so: __strdup: symbol not found
# mv $JAVA_HOME/lib/libjli.so $IDEA_HOME/jbr/lib/libjli.so

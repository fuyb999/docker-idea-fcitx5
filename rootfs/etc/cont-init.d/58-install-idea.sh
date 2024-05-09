#!/bin/sh

set -e # Exit immediately if a command exits with a non-zero status.
set -u # Treat unset variables as an error.

export IDEA_PATH=/usr/local/idea

if [ ! -d "${IDEA_PATH}" ]; then
  mkdir -p $IDEA_PATH
#  IDEA_BIN_ROOT_NAME="$(tar -tf /ideaIU-${IDEA_VERSION}.tar.gz | awk -F "/" '{print $1}' | sed -n '1p')"
  if [ ! -f "/ideaIU-${IDEA_VERSION}.tar.gz" ]; then
    wget https://download.jetbrains.com/idea/ideaIU-$IDEA_VERSION.tar.gz -O /ideaIU-$IDEA_VERSION.tar.gz
  fi
  tar -xzf /ideaIU-$IDEA_VERSION.tar.gz --strip-components=1 -C $IDEA_PATH && \
    echo "-javaagent:/usr/local/ja-netfilter-all/ja-netfilter.jar=jetbrains" >> $IDEA_PATH/bin/idea64.vmoptions && \
    echo "--add-opens=java.base/jdk.internal.org.objectweb.asm=ALL-UNNAMED" >> $IDEA_PATH/bin/idea64.vmoptions && \
    echo "--add-opens=java.base/jdk.internal.org.objectweb.asm.tree=ALL-UNNAMED" >> $IDEA_PATH/bin/idea64.vmoptions

  # fix Error relocating /usr/local/idea/jbr/lib/libjli.so: __strdup: symbol not found
  mv $JAVA_HOME/lib/libjli.so $IDEA_PATH/jbr/lib/libjli.so

fi
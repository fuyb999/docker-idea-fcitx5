#!/bin/sh

set -u # Treat unset variables as an error.

# 在Dockerfile中提前定义
#export HOME=/config

trap "exit" TERM QUIT INT
trap "kill_idea" EXIT

log() {
    echo "[ideasupervisor] $*"
}

LOG_PATH=$HOME/log/idea
JREBEL_SERVER_PORT=8848
JREBEL_JAR_PATH=${XDG_SOFTWARE_HOME}/jrebel-license-server.jar


getpid_idea() {
    PID=UNSET
    if [ -f $HOME/idea.pid ]; then
        PID="$(cat $HOME/idea.pid)"
        # Make sure the saved PID is still running and is associated to
        # Thunder.
        if [ ! -f /proc/$PID/cmdline ] || ! cat /proc/$PID/cmdline | grep -qw "idea"; then
            PID=UNSET
        fi
    fi
    if [ "$PID" = "UNSET" ]; then
        PID="$(ps -ef | grep -w "idea" | grep -vw grep | tr -s ' ' | cut -d' ' -f2)"
    fi
    echo "${PID:-UNSET}"
}

is_idea_running() {
    [ "$(getpid_idea)" != "UNSET" ]
}

start_idea() {
#    LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$JAVA_HOME/lib/server:$JAVA_HOME/lib:$JAVA_HOME/../lib /usr/local/idea/bin/idea.sh > $HOME/log/idea/output.log 2>&1 &
    ${XDG_SOFTWARE_HOME}/ideaIU-${IDEA_VERSION}/bin/idea.sh > $LOG_PATH/output.log 2>&1 &

    # 启动idea后才启动JRebel激活服务，否则启动不了idea
    if [ -f "$JREBEL_JAR_PATH" ]; then
      nohup $JAVA_HOME/bin/java -Dfile.encoding=UTF-8 -Xmx300m -Xms100m -Duser.timezone=GMT+8 \
        -jar $JREBEL_JAR_PATH --server.port=$JREBEL_SERVER_PORT --logging.file.name=$LOG_PATH/jrebel.log > /dev/null 2>&1 &
      echo "waiting for JRebel server... "
      sleep 1
      until curl -s -I http://localhost:$JREBEL_SERVER_PORT/get | grep -q "HTTP/1.1 200"; do sleep 3; done;
      echo "#################################################################################"
      curl --silent -X GET -H "Content-Type: application/json" http://localhost:$JREBEL_SERVER_PORT/get | jq -r '"#### JRebel 激活地址: \(.protocol)\(.licenseUrl)/\(.uuid) \n#### JRebel 激活邮箱: \(.mail)"'
      echo "#################################################################################"
    fi
    # when pack config activate dbeaver
    #export PATH=$JAVA_HOME/bin:$PATH
    #dbeaver &
}

kill_idea() {
    PID="$(getpid_idea)"
    if [ "$PID" != "UNSET" ]; then
        log "Terminating IntelliJ IDEA..."
        kill $PID
        wait $PID
    fi
}

if ! is_idea_running; then
    log "IntelliJ IDEA not started yet.  Proceeding..."
    start_idea
fi

IDEA_NOT_RUNNING=0
while [ "$IDEA_NOT_RUNNING" -lt 60 ]
do
    if is_idea_running; then
        IDEA_NOT_RUNNING=0
    else
        IDEA_NOT_RUNNING="$(expr $IDEA_NOT_RUNNING + 1)"
    fi
    sleep 1
done

log "IntelliJ IDEA no longer running.  Exiting..."

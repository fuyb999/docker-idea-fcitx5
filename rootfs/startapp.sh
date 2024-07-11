#!/bin/sh

set -u # Treat unset variables as an error.

export HOME=/config

trap "exit" TERM QUIT INT
trap "kill_idea" EXIT

log() {
    echo "[ideasupervisor] $*"
}

export IDEA_PATH=${XDG_CONFIG_HOME}/idea

getpid_idea() {
    PID=UNSET
    if [ -f /config/idea.pid ]; then
        PID="$(cat /config/idea.pid)"
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
#    LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$JAVA_HOME/lib/server:$JAVA_HOME/lib:$JAVA_HOME/../lib /usr/local/idea/bin/idea.sh > /config/log/idea/output.log 2>&1 &
    ${IDEA_PATH}/bin/idea.sh > /config/log/idea/output.log 2>&1 &
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

touch /var/run/openbox/openbox.ready &

# 禁用unicode,chttrans(简繁切换)插件，以解决ctrl+shift+f,ctrl+shift+u快捷键冲突
fcitx5 --disable=dbus,wayland,unicode,chttrans,cloudpinyin &

# dbus
#ENV DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/0/bus"
#RUN add-pkg dbus dbus-x11 \
#   &&  mkdir -p /var/run/dbus \
#   &&  chmod 755 /var/run/dbus
#addgroup messagebus
#useradd -g messagebus messagebus
#chown -R root:root /tmp/run/user/app
#dbus-launch --sh-syntax --exit-with-session > /dev/null &
#dbus-daemon --system &
#dbus-launch fcitx5 --disable=wayland,unicode,chttrans &
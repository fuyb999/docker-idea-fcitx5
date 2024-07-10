touch /var/run/openbox/openbox.ready &

# 禁用unicode,chttrans插件，以解决ctrl+shift+f,ctrl+shift+u快捷键冲突
fcitx5 --disable=wayland,unicode,chttrans &

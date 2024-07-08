# Change input method for idea in docker

The docker image provided is based on `jlesage/firefox` image. In addition, `fcitx` is installed and allows you to switch input language from `en` to `pinyin` using the `ctrl + space` keyboard shortcut.

```shell
sudo docker build -t docker-idea:v24.04.1-alpine-glibc .

sudo docker run -d --name=idea \
-e IDEA_VERSION=2024.1 \
-e WEB_LISTENING_PORT=5800 \
-e VNC_LISTENING_PORT=5900 \
-v $HOME/workspaces/config:/config:rw \
-v $HOME/ideaIU-2024.1.tar.gz:/ideaIU-2024.1.tar.gz \
-p 5800:5800 \
-p 5900:5900 \
docker-idea:v24.04.1-alpine-glibc
```

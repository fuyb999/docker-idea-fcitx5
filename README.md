# Change input method for idea in docker

The docker image provided is based on `jlesage/firefox` image. In addition, `fcitx` is installed and allows you to switch input language from `en` to `pinyin` using the `ctrl + space` keyboard shortcut.

```shell
sudo docker build -t docker-idea:ubuntu-22.04-v4.6.3 .

sudo docker run -d --name=idea \
-e JDK_VERSION=17.0.10 \
-e IDEA_VERSION=2024.1 \
-e CONDA_VERSION=2024.06-1 \
-e NODE_VERSION=16.19.1 \
-e WEB_LISTENING_PORT=5800 \
-e VNC_LISTENING_PORT=5900 \
-v $HOME/workspaces/config:/config:rw \
-v $(pwd)/packages:/config/packages \
-p 5800:5800 \
-p 5900:5900 \
docker-idea:ubuntu-22.04-v4.6.3
```

## fcitx5 details
``` shell
fcitx5-diagnose
```

sudo docker run -d --name=idea1 \
-e JDK_VERSION=17.0.10 \
-e IDEA_VERSION=2024.1 \
-e CONDA_VERSION=2024.06-1 \
-e NODE_VERSION=16.19.1 \
-v $HOME/workspaces/config1:/config:rw \
-v $(pwd)/packages:/config/packages \
-p 5901:5900 \
docker-idea:ubuntu-22.04-v4.6.3
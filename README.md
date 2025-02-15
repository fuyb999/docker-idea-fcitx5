# Change input method for idea in docker

The docker image provided is based on `jlesage/firefox` image. In addition, `fcitx` is installed and allows you to switch input language from `en` to `pinyin` using the `ctrl + space` keyboard shortcut.

```shell
sudo docker-compose -p user up
```

## fcitx5 details
``` shell
fcitx5-diagnose
```

## backup config
```shell
cp docker-idea-fcitx5/fcitx5/config /config/xdg/config/fcitx5/
tar --exclude=config/log --exclude=/config/.root/IdeaProjects --exclude=logrotate/logrotate.status --exclude=/config/.bashrc --exclude=/config/packages --exclude=IntelliJIdea2024.1/.lock -jcvf config.tar.bz2 /config/
# include idea plugins
tar --exclude=config/log --exclude=/config/.root/IdeaProjects --exclude=logrotate/logrotate.status --exclude=/config/.bashrc --exclude=/config/packages --exclude=IntelliJIdea2024.1/.lock --exclude=IntelliJIdea2024.1/plugins/*.zip -jcvf - /config/ | split -b 99m -d -a 1 - config-idea2024.1.4-plugins.tar.bz2.
```

```shell
docker run -p 3306:3306 --name mysql \
-v /home/mysql/log:/var/log/mysql \
-v /home/mysql/data:/var/lib/mysql \
-v /home/mysql/conf:/etc/mysql \
--restart=always \
-e MYSQL_ROOT_PASSWORD=123456 \
-d mysql:5.7

sudo apt-get install pcmanfm
```
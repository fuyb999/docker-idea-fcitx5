# Change input method for idea in docker

The docker image provided is based on `jlesage/firefox` image. In addition, `fcitx` is installed and allows you to switch input language from `en` to `pinyin` using the `ctrl + space` keyboard shortcut.

```shell
sudo docker-compose up
```

## fcitx5 details
``` shell
fcitx5-diagnose
```

## backup config
```shell
tar --exclude=config/log --exclude=/config/.bashrc --exclude=/config/packages --exclude=IntelliJIdea2024.1/.lock -jcvf config.tar.bz2 /config/
# include idea plugins
tar --exclude=config/log --exclude=/config/.bashrc --exclude=/config/packages --exclude=IntelliJIdea2024.1/.lock --exclude=IntelliJIdea2024.1/plugins/python.zip -jcvf config-idea2014.1-plugins.tar.bz2 /config/
```
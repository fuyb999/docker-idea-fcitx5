#!/bin/bash

set -e # Exit immediately if a command exits with a non-zero status.
set -u # Treat unset variables as an error.

log() {
    echo "[cont-init.d] $(basename $0): $*"
}

HOME=/config

if [ ${ENABLE_CONDA} -eq 0 ] ; then
  exit 0
fi

if [ -f $HOME/.bashrc ] ; then
  source $HOME/.bashrc
fi

if [ -n "$(which conda)" ]; then
  exit 0
fi

tee $HOME/.condarc << EOF
envs_dirs:
  - ${XDG_CONFIG_HOME}/Anaconda3/envs
  - ${XDG_CONFIG_HOME}/.conda/envs
  - ${XDG_CONFIG_HOME}/conda/conda/envs
pkgs_dirs:
  - ${XDG_CONFIG_HOME}/Anaconda3/pkgs
  - ${XDG_CONFIG_HOME}/.conda/pkgs
  - ${XDG_CONFIG_HOME}/conda/conda/pkgs
auto_activate_base: true
show_channel_urls: true
channels:
  - https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main/
  - https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free/
  - defaults
EOF

chmod 644 $HOME/.condarc

if [ ! -f "${PKG_HOME}/Anaconda3-${CONDA_VERSION}-Linux-x86_64.sh" ]; then
  #apt-get install -y libgl1-mesa-glx libegl1-mesa libxrandr2 libxrandr2 libxss1 libxcursor1 libxcomposite1 libasound2 libxi6 libxtst6
  wget -nc https://repo.anaconda.com/archive/Anaconda3-${CONDA_VERSION}-Linux-x86_64.sh -O ${PKG_HOME}/Anaconda3-${CONDA_VERSION}-Linux-x86_64.sh
fi

if [ ! -d "$ANACONDA_HOME" ]; then
  bash ${PKG_HOME}/Anaconda3-${CONDA_VERSION}-Linux-x86_64.sh -b -p $ANACONDA_HOME -f
fi

# 调用 conda init 初始化conda 在 $HOME/.bashrc 添加初始化脚本 自动激活conda base
#chmod -R +x $ANACONDA_HOME && $ANACONDA_HOME/bin/conda init bash

# [for docker exec] 调用 conda init 初始化conda 在 /config/.bashrc 添加初始化脚本 自动激活conda base
chmod -R +x $ANACONDA_HOME && $ANACONDA_HOME/bin/conda init bash
# [for docker idea terminal] 在/root/.bashrc 添加初始化脚本 在idea terminal中自动激活conda base ($HOME=/config 而不是 /root,所以两个地方都需要初始化)
tee -a /root/.bashrc << EOF
# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="\$('$ANACONDA_HOME/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ \$? -eq 0 ]; then
    eval "\$__conda_setup"
else
    if [ -f "$ANACONDA_HOME/etc/profile.d/conda.sh" ]; then
        . "$ANACONDA_HOME/etc/profile.d/conda.sh"
    else
        export PATH="$ANACONDA_HOME/bin:\$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<
EOF

source /root/.bashrc

#conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free/
#conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main/
#conda config --set show_channel_urls yes
#conda config --set auto_activate_base true

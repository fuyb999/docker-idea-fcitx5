FROM jlesage/baseimage-gui:ubuntu-22.04-v4.6.3

ENV LANG=zh_CN.UTF-8
ENV LANGUAGE=zh_CN:zh
ENV LC_ALL=zh_CN.UTF-8
ENV TZ=Asia/Shanghai
ENV USER_ID=0
ENV GROUP_ID=0

ENV XMODIFIERS=@im=fcitx5
ENV GTK_IM_MODULE=fcitx5
ENV QT_IM_MODULE=fcitx5
ENV WORKSPACES="/root/IdeaProjects"

RUN sed -i "s/us.archive.ubuntu.com/mirrors.tuna.tsinghua.edu.cn/g; s/cn.archive.ubuntu.com/mirrors.tuna.tsinghua.edu.cn/g; s/archive.ubuntu.com/mirrors.tuna.tsinghua.edu.cn/g" /etc/apt/sources.list

# Install pkg
# python3 python3-dev python3-pip \
# openjdk-17-jdk \

RUN add-pkg \
    bash \
    curl \
    wget \
    vim \
    tar \
    bzip2 \
    7zip \
    git \
    unzip \
    zip \
    ca-certificates \
    openssh-server \
    jq \
    language-pack-zh-hans fonts-wqy-zenhei \
    libgl1-mesa-glx libegl1-mesa libxrandr2 libxrandr2 libxss1 libxcursor1 libxcomposite1 libasound2 libxi6 libxtst6 && \
    # Install fcitx and fcitx-pinyin
    # fcitx5 fcitx5-chinese-addons
    add-pkg fcitx5-* && \
        apt-get purge -y dbus fcitx5-module-emoji fcitx5-frontend-* fcitx5-config-qt fcitx5-module-cloudpinyin* fcitx5-keyman fcitx5-sayura fcitx5-anthy fcitx5-chewing fcitx5-hangul fcitx5-kkc fcitx5-m17n fcitx5-mozc fcitx5-rime fcitx5-skk fcitx5-unikey fcitx5-module-lua-* fcitx5-module-pinyinhelper-dev fcitx5-module-punctuation-dev fcitx5-modules-dev && \
        apt-get autoremove -y

# Install ja-netfilter
ADD ja-netfilter-all.zip .
RUN unzip -oq ./ja-netfilter-all.zip -d /usr/local/ja-netfilter-all

COPY ./openbox/startup.sh /etc/services.d/openbox/
RUN chmod +x /etc/services.d/openbox/startup.sh \
  && sed -i 's#touch /var/run/openbox/openbox.ready#sh -c /etc/services.d/openbox/startup.sh#' /etc/services.d/openbox/params

# alt+tab change bettwen idea and firefox
# Apline: RUN sed-patch 's/Navigator/unknown/g' /etc/openbox/main-window-selection.xml
ADD ./openbox /etc/openbox

# Generate and install favicons.
COPY idea.png .
RUN \
    APP_ICON_URL=idea.png && \
    install_app_icon.sh "$APP_ICON_URL"

# Add files.
COPY rootfs/. /
RUN chmod +x /etc/cont-init.d/*.sh

# Set environment variables.
ENV IDEA_VERSION="2024.1"
ENV APP_NAME="IntelliJ IDEA ${IDEA_VERSION}" \
    S6_KILL_GRACETIME=8000

# 提前修改HOME目录到/config 可以解决conda初始化时候需要同时在 /root/.bashrc 与 /config/.bashrc 下添加初始化脚本 系统与idea termnal才会同时生效问题
#ENV HOME=/config
ENV XDG_SOFTWARE_HOME=/opt/apps
ENV PKG_HOME=/config/packages
ENV ENABLE_JDK=1
ENV JDK_VERSION="17.0.10"
ENV JAVA_HOME=$XDG_SOFTWARE_HOME/jdk-$JDK_VERSION

ENV ENABLE_NODE=1
ENV NODE_VERSION="16.19.1"

ENV ENABLE_CONDA=0
ENV CONDA_VERSION="2024.06-1"
ENV ANACONDA_HOME=${XDG_SOFTWARE_HOME}/anaconda3-${CONDA_VERSION}
ENV PATH=$JAVA_HOME/bin:$PATH

# Set internal environment variables.
RUN \
    set-cont-env APP_NAME "$APP_NAME" && \
    set-cont-env APP_VERSION "$IDEA_VERSION" && \
    set-cont-env DOCKER_IMAGE_VERSION "${DOCKER_IMAGE_VERSION}" && \
    true

# Metadata.
LABEL \
      org.label-schema.name="idea" \
      org.label-schema.description="Docker container for IntelliJ IDEA" \
      org.label-schema.version="v2.0.1" \
      org.label-schema.vcs-url="https://gitee.com/HALOBING/docker-idea-fcitx5.git"

WORKDIR "${WORKSPACES}"

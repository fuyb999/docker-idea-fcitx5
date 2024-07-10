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

# ENV JAVA_HOME=/usr
ENV IDEA_VERSION="2024.1"
# ENV IDEA_JDK=$JAVA_HOME
ENV WORKSPACES="/root/IdeaProjects"
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk

RUN sed -i "s/us.archive.ubuntu.com/mirrors.tuna.tsinghua.edu.cn/g; s/cn.archive.ubuntu.com/mirrors.tuna.tsinghua.edu.cn/g; s/archive.ubuntu.com/mirrors.tuna.tsinghua.edu.cn/g" /etc/apt/sources.list

# Install pkg
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
    openjdk-17-jdk \
    openssh-server \
    jq \
    python3 python3-dev python3-pip \
    language-pack-zh-hans fonts-wqy-zenhei

#RUN add-pkg openjdk17-jdk
#RUN wget https://download.oracle.com/java/17/archive/jdk-17.0.10_linux-x64_bin.tar.gz -O jdk-17.0.10_linux-x64_bin.tar.gz
#RUN tar -xzf ./jdk-17.0.10_linux-x64_bin.tar.gz -C /usr/local/

COPY ./openbox/startup.sh /etc/services.d/openbox/
RUN chmod +x /etc/services.d/openbox/startup.sh \
  && sed -i 's#touch /var/run/openbox/openbox.ready#sh -c /etc/services.d/openbox/startup.sh#' /etc/services.d/openbox/params

# alt+tab change bettwen idea and firefox
# Apline: RUN sed-patch 's/Navigator/unknown/g' /etc/openbox/main-window-selection.xml
ADD ./openbox /etc/openbox

# Install ja-netfilter
ADD ja-netfilter-all.zip .
RUN unzip -oq ./ja-netfilter-all.zip -d /usr/local/ja-netfilter-all

# Generate and install favicons.
COPY idea.png .
RUN \
    APP_ICON_URL=idea.png && \
    install_app_icon.sh "$APP_ICON_URL"

# Add files.
COPY rootfs/. /

# Set environment variables.
ENV APP_NAME="IntelliJ IDEA ${IDEA_VERSION}" \
    S6_KILL_GRACETIME=8000

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
      org.label-schema.version="unknown" \
      org.label-schema.vcs-url="https://github.com/romancin/idea-docker"

WORKDIR "${WORKSPACES}"

#RUN wget https://addons.mozilla.org/firefox/downloads/file/4166471/#chinese_simplified_zh_cn_la-117.0.20230912.13654.xpi
#RUN /usr/bin/firefox -silent -install-global-extension ./chinese_simplified_zh_cn_la-117.0.20230912.13654.xpi

# Install fcitx and fcitx-pinyin
#RUN add-pkg \
#    fcitx5 fcitx5-chinese-addons
# kde-config-fcitx5
RUN add-pkg fcitx5-* && \
    apt-get purge -y fcitx5-config-qt fcitx5-module-cloudpinyin* fcitx5-keyman fcitx5-sayura fcitx5-anthy fcitx5-chewing fcitx5-hangul fcitx5-kkc fcitx5-m17n fcitx5-mozc fcitx5-rime fcitx5-skk fcitx5-unikey fcitx5-module-lua-* fcitx5-module-pinyinhelper-dev fcitx5-module-punctuation-dev fcitx5-modules-dev && \
    apt-get autoremove -y
#COPY fcitx5/. /config/xdg/config/fcitx5/
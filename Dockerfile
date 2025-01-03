FROM fuyb/baseimage-gui-fcitx5:ubuntu-22.04-v4.6.7

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
    p7zip-full \
    git \
    unzip \
    zip \
    ca-certificates \
    openssh-server \
    jq \
    language-pack-zh-hans fonts-wqy-zenhei \
    libpulse-mainloop-glib0 \
    libgl1-mesa-glx libegl1-mesa libxrandr2 libxrandr2 libxss1 libxcursor1 libxcomposite1 libasound2 libxi6 libxtst6 \
    libswt-gtk-4-java libxtst6 libxss1 libgtk2.0-0 libgconf-2-4

RUN add-pkg  --no-install-recommends bash-completion \
                        less \
                        mlocate \
                        nano \
                        net-tools \
                        p7zip-full \
                        patch \
                        pciutils \
                        pkg-config \
                        procps \
                        psmisc \
                        psutils \
                        rsync \
                        xmlstarlet \
                        xz-utils \
                        python3 \
                        python3-numpy \
                        python3-pip \
                        python3-setuptools \
                        python3-venv

# Install X Server requirements
# TODO: Refine this list of packages to only what is required.
ENV \
    XORG_SOCKET_DIR="/tmp/.X11-unix" \
    XDG_RUNTIME_DIR="/tmp/.X11-unix/run" \
    XDG_SESSION_TYPE="x11" \
    FORCE_X11_DUMMY_CONFIG="false"
RUN \
    add-pkg --no-install-recommends \
            avahi-utils \
            dbus-x11 \
            libxcomposite-dev \
            libxcursor1 \
            wmctrl \
            libfuse2 \
            x11-utils \
            x11-xfs-utils \
            x11-xkb-utils \
            x11-xserver-utils \
            xauth \
            xbindkeys \
            xclip \
            xcvt \
            xdotool \
            xfishtank \
            xfonts-base \
            xinit \
            xorg \
            xserver-xorg-core \
            xserver-xorg-input-evdev \
            xserver-xorg-input-libinput \
            xserver-xorg-legacy \
            xserver-xorg-video-all \
            xserver-xorg-video-dummy

RUN \
    add-pkg --no-install-recommends \
            libdbus-1-3 \
            libegl1 \
            libgtk-3-0 \
            libgtk2.0-0 \
            libsdl2-2.0-0 \
            fonts-vlgothic \
            gedit \
            imagemagick \
            msttcorefonts \
            xdg-utils \
            xfce4 \
            xfce4-terminal \
            tcpdump \
            xprintidle

RUN add-pkg supervisor kmod

RUN rm -f \
            /usr/share/applications/software-properties-drivers.desktop \
            /usr/share/applications/xfce4-about.desktop \
            /usr/share/applications/xfce4-session-logout.desktop \
            # Hide these apps. They can be displayed if a user really wants them.
            && sed -i '/[Desktop Entry]/a\NoDisplay=true' /usr/share/applications/xfce4-accessibility-settings.desktop \
            && sed -i '/[Desktop Entry]/a\NoDisplay=true' /usr/share/applications/xfce4-color-settings.desktop \
            && sed -i '/[Desktop Entry]/a\NoDisplay=true' /usr/share/applications/xfce4-mail-reader.desktop \
            && sed -i '/[Desktop Entry]/a\NoDisplay=true' /usr/share/applications/xfce4-web-browser.desktop \
            && sed -i '/[Desktop Entry]/a\NoDisplay=true' /usr/share/applications/vim.desktop \
            && sed -i '/[Desktop Entry]/a\NoDisplay=true' /usr/share/applications/thunar-settings.desktop \
            && sed -i '/[Desktop Entry]/a\NoDisplay=true' /usr/share/applications/thunar.desktop \
            && sed -i '/[Desktop Entry]/a\NoDisplay=true' /usr/share/applications/display-im6.q16.desktop \
            # These are named specifically for Debain
            # Force these apps to be "System" Apps rather than "Categories=System;Utility;Core;GTK;Filesystem;"
            && sed -i 's/^Categories=.*$/Categories=System;/' /usr/share/applications/xfce4-appfinder.desktop \
            && sed -i 's/^Categories=.*$/Categories=System;/' /usr/share/applications/thunar-bulk-rename.desktop \
            && sed -i 's/^Categories=.*$/Categories=System;/' /usr/share/applications/org.gnome.gedit.desktop

COPY ./openbox/startup.sh /etc/services.d/openbox/
RUN chmod +x /etc/services.d/openbox/startup.sh \
  && sed -i 's#touch /var/run/openbox/openbox.ready#sh -c /etc/services.d/openbox/startup.sh#' /etc/services.d/openbox/params

# alt+tab change bettwen idea and firefox
# Apline: RUN sed-patch 's/Navigator/unknown/g' /etc/openbox/main-window-selection.xml
ADD ./openbox /etc/openbox

# Add files.
COPY rootfs/. /
RUN chmod +x /etc/cont-init.d/*.sh

# Generate and install favicons.
COPY idea.png .
RUN \
    APP_ICON_URL=idea.png && \
    install_app_icon.sh "$APP_ICON_URL" && \
    rm -rf ./idea.png

# Custom settings.
RUN sed -i 's|add_user --allow-duplicate app "$USER_ID" "$GROUP_ID"|add_user --allow-duplicate app "$USER_ID" "$GROUP_ID" /home/app|g' /etc/cont-init.d/10-init-users.sh && \
    sed -i -e "s|rm -rf .*|find /tmp -mindepth 1 -maxdepth 1 ! -name '.X11-unix' -exec rm -rf {} +|" /etc/cont-init.d/10-clean-tmp-dir.sh

ENV \
    DISPLAY_CDEPTH="24" \
    DISPLAY_REFRESH="120" \
    DISPLAY_SIZEH="1080" \
    DISPLAY_SIZEW="1920" \
    DISPLAY_VIDEO_PORT="DFP" \
    DISPLAY=":55"

# Set environment variables.
ENV IDEA_VERSION="2024.1"
ENV APP_NAME="IntelliJ IDEA ${IDEA_VERSION}" \
    S6_KILL_GRACETIME=8000

# 提前修改HOME目录到/config 可以解决conda初始化时候需要同时在 /root/.bashrc 与 /config/.bashrc 下添加初始化脚本 系统与idea termnal才会同时生效问题
ENV HOME=/config
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

ENV ENABLE_FIREFOX=1
ENV FIREFOX_VERSION="128.0"

ENV ENABLE_DBEAVER=1
ENV DBEAVER_VERSION="ee-24.2.0"

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

#USER $DEFAULT_USER # 不能设置为普通用户 10-init-users.sh 没有权限执行
WORKDIR "${WORKSPACES}"

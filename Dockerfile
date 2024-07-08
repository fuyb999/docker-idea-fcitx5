FROM jlesage/firefox:v24.04.1

ENV LANG=zh_CN.UTF-8
ENV TZ=Asia/Shanghai
ENV USER_ID=0
ENV GROUP_ID=0

ENV XMODIFIERS=@im=fcitx5
ENV GTK_IM_MODULE=fcitx5
ENV QT_IM_MODULE=fcitx5

ENV GLIBC_VERSION 2.35-r1
# ENV JAVA_HOME=/usr
ENV IDEA_VERSION="2024.1"
# ENV IDEA_JDK=$JAVA_HOME
ENV WORKSPACES="/root/IdeaProjects"

RUN sed -i "s/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g" /etc/apk/repositories

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
    font-wqy-zenhei \
    openjdk17-jdk \
    openssh-client \
    openssh-server \
    openssh \
    jq py3-configobj py3-pip py3-setuptools python3 python3-dev

# Download and install glibc for idea jbr(openjdk) : idea editor fcitx5: https://github.com/jeanblanchard/docker-alpine-glibc/
RUN curl -Lo /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub && \
  curl -Lo glibc.apk "https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk" && \
  curl -Lo glibc-bin.apk "https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-bin-${GLIBC_VERSION}.apk" && \
  apk add --force-overwrite glibc-bin.apk glibc.apk && \
  /usr/glibc-compat/sbin/ldconfig /lib /usr/glibc-compat/lib && \
  echo 'hosts: files mdns4_minimal [NOTFOUND=return] dns mdns4' >> /etc/nsswitch.conf

#RUN add-pkg openjdk17-jdk
#RUN wget https://download.oracle.com/java/17/archive/jdk-17.0.10_linux-x64_bin.tar.gz -O jdk-17.0.10_linux-x64_bin.tar.gz
#RUN tar -xzf ./jdk-17.0.10_linux-x64_bin.tar.gz -C /usr/local/

# Install fcitx and fcitx-pinyin
RUN add-pkg \
    boost1.84-iostreams --repository=https://mirrors.ustc.edu.cn/alpine/edge/main
RUN add-pkg \
    fcitx5 fcitx5-chinese-addons --repository=https://mirrors.ustc.edu.cn/alpine/edge/testing

COPY ./openbox/startup.sh /etc/services.d/openbox/
RUN chmod +x /etc/services.d/openbox/startup.sh \
  && sed -i 's#touch /var/run/openbox/openbox.ready#sh -c /etc/services.d/openbox/startup.sh#' /etc/services.d/openbox/params

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

# alt+tab change bettwen idea and firefox
RUN sed-patch 's/Navigator/unknown/g' /etc/openbox/main-window-selection.xml

# Metadata.
LABEL \
      org.label-schema.name="idea" \
      org.label-schema.description="Docker container for IntelliJ IDEA" \
      org.label-schema.version="unknown" \
      org.label-schema.vcs-url="https://github.com/romancin/idea-docker"

WORKDIR "${WORKSPACES}"

#COPY --from=jetbrains/runtime:jbr21env_musl_x64 /jdk20 /usr/local/jdk21
#ENV IDEA_JDK=/usr/lib/jvm/java-17-openjdk
#ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/idea/jbr/lib/server

ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk
# ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$JAVA_HOME/lib/server:$JAVA_HOME/lib:$JAVA_HOME/../lib

RUN mkdir -p /root/fcitx
COPY fcitx/. /root/fcitx/
#RUN wget https://addons.mozilla.org/firefox/downloads/file/4166471/#chinese_simplified_zh_cn_la-117.0.20230912.13654.xpi
#RUN /usr/bin/firefox -silent -install-global-extension ./chinese_simplified_zh_cn_la-117.0.20230912.13654.xpi

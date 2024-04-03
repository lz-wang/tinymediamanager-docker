#
# TinyMediaManager Dockerfile
#
FROM jlesage/baseimage-gui:alpine-3.12-glibc

# Define software versions.
ARG JAVAJRE_VERSION=8.342.07.4
ARG TMM_VERSION=3.1.18

# Define software download URLs.
# ARG TMM_URL=https://release.tinymediamanager.org/v3/dist/tinyMediaManager-${TMM_VERSION}-linux-amd64.tar.gz
ARG TMM_URL=https://archive.tinymediamanager.org/v${TMM_VERSION}/tmm_${TMM_VERSION}_linux.tar.gz
ARG JAVAJRE_URL=https://corretto.aws/downloads/resources/${JAVAJRE_VERSION}/amazon-corretto-${JAVAJRE_VERSION}-linux-x64.tar.gz
ENV JAVA_HOME=/opt/jre/bin
ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/jre/bin

# Define working directory.
WORKDIR /tmp

# Download TinyMediaManager
RUN mkdir -p /defaults && \
    wget ${TMM_URL} -O /defaults/tmm.tar.gz

# Use TUNA mirror to speed download
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories

# Download and install Oracle JRE.
# NOTE: This is needed only for the 7-Zip-JBinding workaround.
RUN add-pkg --virtual build-dependencies curl && \
    mkdir /opt/jre && \
    curl -# -L ${JAVAJRE_URL} | tar -xz --strip 2 -C /opt/jre amazon-corretto-${JAVAJRE_VERSION}-linux-x64/jre && \
    del-pkg build-dependencies

# Install dependencies.
RUN add-pkg \
        # For the 7-Zip-JBinding workaround, Oracle JRE is needed instead of
        # the Alpine Linux's openjdk native package.
        # The libstdc++ package is also needed as part of the 7-Zip-JBinding
        # workaround.
        #openjdk8-jre \
        libmediainfo \
        ttf-dejavu \
        bash

# Chinese support https://alpine.pkgs.org/3.19/alpine-community-x86_64/font-wqy-zenhei-0.9.45-r3.apk.html
RUN wget http://dl-cdn.alpinelinux.org/alpine/v3.19/community/x86_64/font-wqy-zenhei-0.9.45-r3.apk && \
    apk add --allow-untrusted font-wqy-zenhei-0.9.45-r3.apk

# Maximize only the main/initial window.
# It seems this is not needed for TMM 3.X version.
#RUN \
#    sed-patch 's/<application type="normal">/<application type="normal" title="tinyMediaManager \/ 3.0.2">/' \
#        /etc/xdg/openbox/rc.xml

# Generate and install favicons.
RUN APP_ICON_URL=https://www.tinymediamanager.org/images/tmm.png && \
    install_app_icon.sh "$APP_ICON_URL"

# Add files.
COPY rootfs/ /

# Set environment variables.
ENV APP_NAME="TinyMediaManager" \
    S6_KILL_GRACETIME=8000

# Define mountable directories.
VOLUME ["/config"]
VOLUME ["/media"]

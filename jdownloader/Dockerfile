FROM alpine:latest

ENV USER_UID="1002" \
    USER_NAME="jdownloader" \
    JDOWNLOADER_LINK="http://installer.jdownloader.org/JDownloader.jar" \
    JDPATH="/jdownloader" \
    LANG='C.UTF-8' \
    LANGUAGE='C.UTF-8'
    
ENV JAVA_HOME=/opt/jdk \
    PATH=${PATH}:/opt/jdk/bin \
    GLIBC_VERSION=2.30-r0

# alpine - openjdk8-jre-base java-jna openjdk8-jre-lib libstdc++  glibc-bin glibc-i18n
# libstdc++ and glibc-i18n needed for jdownloader building 7zip Package
RUN set -ex \
    && apk add --no-cache --update wget bash ca-certificates su-exec curl libstdc++ tar openjdk8-jre-base \
    && wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub \
    && wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk \
    && wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-bin-${GLIBC_VERSION}.apk \
    && wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-i18n-${GLIBC_VERSION}.apk \
    && apk add glibc-${GLIBC_VERSION}.apk glibc-bin-${GLIBC_VERSION}.apk glibc-i18n-${GLIBC_VERSION}.apk \
#    && ( /usr/glibc-compat/bin/localedef --force --inputfile POSIX --charmap UTF-8 C.UTF-8 || true ) \
#    && echo "export $LANG" > /etc/profile.d/locale.sh \
#    && /usr/glibc-compat/sbin/ldconfig /lib /usr/glibc-compat/lib \
    && mkdir -p /opt \
    && mkdir -p ${JDPATH} \
    && echo "adding $USER_NAME as Group and User" \
    && addgroup -g ${USER_UID} ${USER_NAME} \
    && adduser -D -u ${USER_UID} -G ${USER_NAME} -s /bin/sh -h /${USER_NAME} ${USER_NAME} \
#    && echo "Downloading jDownloader jar File" \
#    && wget -O ${JDPATH}/JDownloader.jar --progress=bar:force ${JDOWNLOADER_LINK} \
    && apk del wget curl tar \
    && rm -rf /tmp/* /var/cache/apk/* /var/lib/apk/lists/*

ADD start.sh /start.sh
ADD JDownloader.jar ${JDPATH}/JDownloader.jar
RUN chmod +x /start.sh

#USER $USER_NAME
VOLUME ${JDPATH}/cfg
WORKDIR ${JDPATH}
CMD ["/start.sh"]

# Run Commands
#-v /pathtoconfig/jdownloader:/jdownloader/cfg
#-v /downloadpath/:/jdownloader/Downloads
FROM alpine as download
WORKDIR /build
# 获取github release 最新版本
ARG TARGETARCH
COPY download.sh ./download.sh
RUN sh ./download.sh ${TARGETARCH}


FROM ubuntu:18.04
LABEL MAINTAINER=slcnx
RUN apt update &&  apt install  libicu-dev libgssapi-krb5-2 libssl-dev -y --fix-missing && \
    apt install -y locales && rm -rf /var/lib/apt/lists/* && localedef -i zh_CN -c -f UTF-8 -A /usr/share/locale/locale.alias zh_CN.UTF-8
ENV LANG zh_CN.utf8
WORKDIR /app
COPY  --from=download /build/fastgithub/ /app
EXPOSE 38457
CMD /app/fastgithub
FROM node:16-alpine AS build
WORKDIR /app
ENV DOCKER=YES
RUN apk add --no-cache alpine-sdk && \
    git clone https://github.com/Chinachu/Mirakurun.git . && \
    npm install && \
    npm run build && \
    npm install -g --unsafe-perm --production

FROM node:16-alpine
COPY --from=build /usr/local/lib/node_modules/mirakurun /app
WORKDIR /app
RUN echo "@testing http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
    apk add --no-cache \
        ca-certificates \
        make \
        gcc \
        g++ \
        pkgconf \
        pcsc-lite \
        pcsc-lite-openrc \
        openrc \
        pcsc-lite-dev \
        ccid \
        v4l-utils-libs \
        pcsc-tools@testing \
        v4l-utils-dvbv5 \
        bash \
        libc6-compat && \
    mkdir /run/openrc && \
    touch /run/openrc/softlevel && \
    sed -i -e 's/cgroup_add_service$/# cgroup_add_service/g' /lib/rc/sh/openrc-run.sh && \
    rc-status
COPY --from=build /usr/local/lib/node_modules/mirakurun /app
CMD ["./docker/container-init.sh"]
EXPOSE 40772 9229

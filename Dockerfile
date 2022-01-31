FROM node:16-alpine AS build
WORKDIR /app
ENV DOCKER=YES
RUN apk add --no-cache alpine-sdk \
&& npm install mirakurun -g --unsafe-perm --production

FROM node:16-alpine
WORKDIR /app
RUN apk add --no-cache \
ca-certificates \
make \
gcc \
g++ \
pkgconf \
pcsc-lite-openrc \
openrc \
pcsc-lite-dev \
ccid \
v4l-utils-dev \
v4l-utils-libs \
v4l-utils-dvbv5 \
bash \
pcsc-lite-libs \
pcsc-lite \
libc6-compat \
&& echo "@testing http://dl-cdn.alpinelinux.org/alpine/edge/testing" >>/etc/apk/repositories \
&& apk add --no-cache pcsc-tools@testing
COPY --from=build /usr/local/lib/node_modules/mirakurun /app
CMD mkdir /run/openrc \
&& touch /run/openrc/softlevel \
&& sed -i -e 's/cgroup_add_service$/# cgroup_add_service/g' /lib/rc/sh/openrc-run.sh \
&& rc-status \
&& ./docker/container-init.sh"
EXPOSE 40772 9229

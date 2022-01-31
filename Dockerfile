# mirakurun-build
FROM collelog/buildenv:node16-alpine AS mirakurun-build

ENV DOCKER="YES"
WORKDIR /tmp
RUN curl -kfsSLo mirakurun.zip http://github.com/Chinachu/Mirakurun/archive/refs/heads/master.zip
RUN unzip mirakurun.zip
RUN chmod -R 755 ./Mirakurun-master
RUN mv ./Mirakurun-master /app
WORKDIR /app
RUN npm install
RUN npm run build
RUN npm install -g --unsafe-perm --production
RUN npm cache verify
RUN rm -rf /tmp/* /var/cache/apk/*


# final image
FROM node:16-alpine
ENV LD_LIBRARY_PATH=/usr/local/lib64:/usr/local/lib

# mirakurun
COPY --from=mirakurun-build /usr/local/lib/node_modules/mirakurun /app

RUN set -eux && \
	apk upgrade --no-cache --update-cache && \
	apk add --no-cache --update-cache \
                libc6-compat \
		bash \
		boost \
		ca-certificates \
		ccid \
		curl \
		libstdc++ \
		openrc \
		pcsc-lite \
		pcsc-lite-libs \
		socat \
		tzdata \
		v4l-utils-dvbv5 && \
	echo http://dl-cdn.alpinelinux.org/alpine/edge/testing >> /etc/apk/repositories && \
	apk add --no-cache --update-cache \
		pcsc-tools && \
	\
	mkdir /run/openrc && \
	touch /run/openrc/softlevel && \
	\
	sed -i -e 's/cgroup_add_service$/# cgroup_add_service/g' /lib/rc/sh/openrc-run.sh && \
	\
	rc-status && \
	\
	mkdir /etc/dvbv5 && \
	cd /etc/dvbv5 && \
	curl -fsSLO https://raw.githubusercontent.com/Chinachu/dvbconf-for-isdb/master/conf/dvbv5_channels_isdbs.conf && \
	curl -fsSLO https://raw.githubusercontent.com/Chinachu/dvbconf-for-isdb/master/conf/dvbv5_channels_isdbt.conf && \
	\
	# cleaning
	rm -rf /tmp/* /var/tmp/*

WORKDIR /app

EXPOSE 40772
EXPOSE 9229
ENTRYPOINT []
CMD ["/app/docker/container-init.sh"]

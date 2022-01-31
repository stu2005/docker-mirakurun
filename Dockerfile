# mirakurun-build
FROM node:16-alpine AS mirakurun-build

ENV DOCKER="YES"
RUN npm install mirakurun -g --unsafe-perm --production
# final image
FROM node:16-alpine

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
	# cleaning
	rm -rf /tmp/* /var/tmp/*

WORKDIR /app

EXPOSE 40772
EXPOSE 9229
ENTRYPOINT []
CMD ["/app/docker/container-init.sh"]

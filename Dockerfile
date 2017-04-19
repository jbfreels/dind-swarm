FROM docker:1.13.1-dind
LABEL maintainer "J.B. Freels <jbfreels@terragotech.com>"

ARG DIND_PORT=3000

ENV DIND_WORKERS 3 \
    DIND_PORT $DIND_PORT

EXPOSE $DIND_PORT

RUN apk add --no-cache \
		git \
		openssh-client \
		socat
	
COPY dind-entrypoint.sh /usr/local/bin/

ENTRYPOINT ["dind-entrypoint.sh"]

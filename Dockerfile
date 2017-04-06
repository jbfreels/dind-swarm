FROM docker:1.13.1-dind
LABEL maintainer "J.B. Freels <jbfreels@terragotech.com>

ENV NUM_WORKERS 3

RUN apk add --no-cache \
		git \
		openssh-client \
		socat
	
COPY dind-entrypoint.sh /usr/local/bin/

EXPOSE 3000

ENTRYPOINT ["dind-entrypoint.sh"]

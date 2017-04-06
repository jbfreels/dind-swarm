#!/bin/sh

set -e

dockerd \
		--host=unix:///var/run/docker.sock \
		--storage-driver=vfs &

sleep 5

docker run -v /raft:/var/lib/docker/swarm/raft \
	-h master \
	-p 2375:2375 \
	--privileged \
	--name=master \
	-d $@ docker:1.13.1-dind \
	> /dev/null 2> /dev/null && \
	echo "master started" || \
	echo "master could not start" 

for i in $(seq "${NUM_WORKERS}"); do
	docker run -d --privileged \
		--name worker-${i} \
		-h worker-${i} \
		docker:1.13.1-dind \
		> /dev/null 2> /dev/null && \
		echo worker-${i} up \
		|| echo worker-${i} failed to start
done

sleep 1

docker exec master docker swarm init \
	> /dev/null 2> /dev/null && \
	echo master initialized || \
	echo master could not initialize

TOKEN=`docker exec master docker swarm join-token worker -q`
IP=`docker inspect --format '{{ .NetworkSettings.IPAddress }}' master`

for i in $(seq "${NUM_WORKERS}"); do
	docker exec worker-${i} docker swarm join --token $TOKEN $IP:2377 > /dev/null 2> /dev/null && echo worker-${i} joined swarm || echo worker-${i} failed to join swarm
done

socat TCP-LISTEN:3000,fork TCP:127.0.0.1:2375 &

docker attach master

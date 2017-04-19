#!/bin/sh

DIND_PORT=${DIND_PORT:-3000}
DIND_MASTER_NAME=${DIND_MASTER_NAME:-master}
DIND_MASTER_IMAGE=${DIND_MASTER_IMAGE:-docker:1.13.1-dind}
DIND_WORKER_IMAGE=${DIND_WORKER_IMAGE:-docker:1.13.1-dind}
DIND_WORKERS=${DIND_WORKERS:-3}
DIND_STORAGE_DRIVER=${DIND_STORAGE_DRIVER:-vfs}

echo "PORT: ${DIND_PORT}"
set -e

dockerd \
		--host=unix:///var/run/docker.sock \
		--storage-driver=vfs &

# wait for daemon
sleep 5

# create master
docker run -v /raft:/var/lib/docker/swarm/raft \
	-h master \
	-p 2375:2375 \
	--privileged \
	--name=${DIND_MASTER_NAME} \
	-d $@ ${DIND_MASTER_IMAGE} \
	> /dev/null 2> /dev/null && \
	echo "master up" || \
	echo "master failed to start" 

# create workers
for i in $(seq "${NUM_WORKERS}"); do
	docker run -d --privileged \
		--name worker-${i} \
		-h worker-${i} \
		${DIND_WORKER_IMAGE} \
		> /dev/null 2> /dev/null && \
		echo worker-${i} up \
		|| echo worker-${i} failed to start
done

sleep 1

# init swarm
docker exec master docker swarm init \
	> /dev/null 2> /dev/null && \
	echo master initialized || \
	echo master could not initialize

# get token
TOKEN=`docker exec master docker swarm join-token worker -q`
IP=`docker inspect --format '{{ .NetworkSettings.IPAddress }}' master`

# join wokers to swarm
for i in $(seq "${NUM_WORKERS}"); do
	docker exec worker-${i} docker swarm join --token $TOKEN $IP:2377 > /dev/null 2> /dev/null && \
    echo worker-${i} joined swarm || \
    echo worker-${i} failed to join swarm
done

socat TCP-LISTEN:${DIND_PORT},fork TCP:127.0.0.1:2375 &

docker attach master

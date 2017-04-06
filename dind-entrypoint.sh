#!/bin/sh

set -e

dockerd \
		--host=unix:///var/run/docker.sock \
		--storage-driver=vfs &

sleep 5

docker run -v /raft:/var/lib/docker/swarm/raft -h swarm-master -p 2375:2375 --privileged --name=swarm-master -d $@ docker:1.13.1-dind > /dev/null 2> /dev/null && echo "swarm-master started" || echo "swarm-master could not start" 
docker run -h swarm-slave1 --privileged --name=swarm-slave1 -d docker:1.13.1-dind > /dev/null 2> /dev/null && echo "swarm-slave1 started" || echo "swarm-slave1 could not start" 
docker run -h swarm-slave2 --privileged --name=swarm-slave2 -d docker:1.13.1-dind > /dev/null 2> /dev/null && echo "swarm-slave2 started" || echo "swarm-slave2 could not start" 
docker run -h swarm-slave3 --privileged --name=swarm-slave3 -d docker:1.13.1-dind > /dev/null 2> /dev/null && echo "swarm-slave3 started" || echo "swarm-slave3 could not start" 

sleep 1

docker exec swarm-master docker swarm init > /dev/null 2> /dev/null && echo "swarm-master initialized"  || echo "swarm-slave1 could not be initialized"

TOKEN=`docker exec swarm-master docker swarm join-token worker -q`
IP=`docker inspect --format '{{ .NetworkSettings.IPAddress }}' swarm-master`

docker exec swarm-slave1 docker swarm join --token $TOKEN $IP:2377 > /dev/null 2> /dev/null && echo "swarm-slave1 joined" || echo "swarm-slave1 could not join"
docker exec swarm-slave2 docker swarm join --token $TOKEN $IP:2377 > /dev/null 2> /dev/null && echo "swarm-slave2 joined" || echo "swarm-slave2 could not join"
docker exec swarm-slave3 docker swarm join --token $TOKEN $IP:2377 > /dev/null 2> /dev/null && echo "swarm-slave3 joined" || echo "swarm-slave3 could not join"

socat TCP-LISTEN:3000,fork TCP:127.0.0.1:2375 &

docker attach swarm-master

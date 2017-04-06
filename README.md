# Docker in Docker Swarm
see original: https://github.com/ThatsMrTalbot/docker-dind-swarm

hub: https://hub.docker.com/r/thatsmrtalbot/dind-swarm/

Forked this project to adapt it to docker 1.13.1.  I use this to test my custom swarm CLI and API to ochestrate containers.

I guess this is the flavor of the month since docker-machine seems to be dead :)

## Building
`docker build -t dind-swarm`

## Running
`docker run --privileged --name swarm -d -p 3000:3000 --rm dind-swarm`

## Verify
The swarm will take a minute or so to start up, as long as it hasn't exited, you'll get EOF error or valid output

`docker -H tcp://127.0.0.1:3000 info`

`docker -H tcp://127.0.0.1:3000 node ls`

`docker -H tcp://127.0.0.1:3000 node promote swarm-slave1`

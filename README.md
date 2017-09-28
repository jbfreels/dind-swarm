# Update
You shouldn't use this, as you can now have a single node swarm which is more ideal to test with than a docker-in-docker swarm.

`docker swarm init` on your local and you can now test swarm command, create services, etc..

# Docker in Docker Swarm
Docker 1.13.1.  I use this to test my custom swarm CLI and API to ochestrate containers.

I guess this is the flavor of the month since docker-machine seems to be dead :)

## Building
`docker build -t dind-swarm`

## Running
`docker run --privileged --name swarm -d -p 3000:3000 --rm dind-swarm`

You can specify the mount of workers (default=3) by setting NUM_WORKERS...

`docker run --privileged --name swarm -d -p 3000:3000 --rm `**`-e NUM_WORKERS=5`**` dind-swarm`

## Verify
The swarm will take a minute or so to start up, as long as it hasn't exited, you'll get EOF error or valid output

`docker -H tcp://127.0.0.1:3000 info`

`docker -H tcp://127.0.0.1:3000 node ls`

`docker -H tcp://127.0.0.1:3000 node promote swarm-slave1`

## Environment Variables
```bash
DIND_PORT=3000                        # port exposed to host
DIND_MASTER_NAME=master               # hostname for master node
DIND_MASTER_IMAGE=docker:1.13.1-dind  # image used to run master node
DIND_WORKER_IMAGE=docker:1.13.1-dind  # image used to run worker nodes
DIND_WORKERS=3                        # (previously NUM_WORKERS) number of workers to spawn
DIND_STORAGE_DRIVER=vfs               # storage driver to use
```
### Change Default Port
```bash
export DIND_PORT=8765
docker run --privileged {...} -p $DIND_PORT:$DIND_PORT --env DIND_PORT=$DIND_PORT dind-swarm
docker -H tcp://127.0.0.1:$DIND_PORT info
```
## Insecure Registry
If you have an insecure registry on your host or network, checkout the registry branch.

`git checkout registry`

Now you can pass REGISTRY as an environment variable and it will be passed to the workers.

`docker run --privileged {...} `**`REGISTRY=MY_LOCAL_REGISTRY:5000`**` dind-swarm`

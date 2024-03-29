#!/bin/bash

set -e

trap "echo; exit" INT
trap "echo; exit" HUP

cp .env.example .env

# try to fetch public IP address if value not set in .env
NAME_PROJECT_FALLBACK=kobold-test
NODE_ENV_FALLBACK="development"
NONROOT_PASSWORD_FALLBACK="password"
PORT_TRUNK_FALLBACK=8080
PUBLIC_IP_ADDRESS_FALLBACK=$(wget http://ipecho.net/plain -O - -q ; echo)
ROOT_PASSWORD_FALLBACK="password"

# assign fallback values for environment variables from .env.example incase
# not declared in .env file. alternative approach is `echo ${X:=$X_FALLBACK}`
source $(dirname "$(realpath "${BASH_SOURCE[0]}")")/.env.example
source $(dirname "$(realpath "${BASH_SOURCE[0]}")")/.env
export NAME_PROJECT=$(jq '.name' $PWD/Cargo.toml | sed 's/\"//g')
export NONROOT_PASSWORD PORT_TRUNK PUBLIC_IP_ADDRESS ROOT_PASSWORD
echo ${NAME_PROJECT:=$NAME_PROJECT_FALLBACK}
echo ${NODE_ENV:=$NODE_ENV_FALLBACK}
# echo ${NONROOT_PASSWORD:=$NONROOT_PASSWORD_FALLBACK}
echo ${PORT_TRUNK_FALLBACK:=$PORT_TRUNK_FALLBACK}
echo ${PUBLIC_IP_ADDRESS:=$PUBLIC_IP_ADDRESS_FALLBACK}
# echo ${ROOT_PASSWORD:=$ROOT_PASSWORD_FALLBACK}

if [ "$NODE_ENV" != "development" ]; then
    printf "\nError: NODE_ENV should be set to development in .env\n";
    kill "$PPID"; exit 1;
fi
printf "\n*** Started building Docker container."
printf "\n*** Please wait... \n***"
# DOCKER_BUILDKIT=0 docker compose -f docker-compose-dev.yml up --build -d
DOCKER_BUILDKIT=0 docker build -f Dockerfile \
    --build-arg NAME_PROJECT=${NAME_PROJECT} \
    --build-arg NODE_ENV=${NODE_ENV_FALLBACK} \
    --build-arg NONROOT_PASSWORD=${NONROOT_PASSWORD} \
    --build-arg PORT_TRUNK=${PORT_TRUNK} \
    --build-arg PUBLIC_IP_ADDRESS=${PUBLIC_IP_ADDRESS} \
    --build-arg ROOT_PASSWORD=${ROOT_PASSWORD} \
    -t ${NAME_PROJECT}:latest .
if [ $? -ne 0 ]; then
    kill "$PPID"; exit 1;
fi
printf "\n*** Finished building Docker container.\n"

if [ "$PUBLIC_IP_ADDRESS" != "" ]; then
    # run docker container and execute command
    # FIXME - does not update website when make changes in src/ directory
    RUST_BACKTRACE=1 docker run --net host --privileged --user root --rm -it --name kobold-test \
        -v './src:/kobold-test/src' \
        kobold-test trunk serve --address=${PUBLIC_IP_ADDRESS} --watch dist --watch target --watch src

    # run docker container daemon in background and access container using nonroot user
    # and enter password and enter commands in container shell
    # FIXME - does not work with nonroot user `failed to start `cargo metadata`: Permission denied (os error 13)`
    # RUST_BACKTRACE=1 docker run --net host --privileged --user root --rm -it -d --name kobold-test kobold-test
    # docker exec -it --user nonroot kobold-test /bin/bash
    # run in docker container shell
    # trunk serve --address=${PUBLIC_IP_ADDRESS}

    CONTAINER_ID=docker ps --filter name=kobold-test --format 'json' | jq -r '.ID'
    printf "\n*** Public IP address: http://${PUBLIC_IP_ADDRESS}:${PORT_TRUNK}\n***\n";
    printf "\n*** Running in Docker container ID: ${CONTAINER_ID}"
    printf "\n*** Docker volumes for container ID:"
    docker inspect -f '{{ .Mounts }}' ${CONTAINER_ID}
fi

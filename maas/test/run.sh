#!/usr/bin/env bash

this_dir=$(dirname ${BASH_SOURCE[0]})
env_file=${this_dir}/.env

podman build -t maas:3.5 ${this_dir}/../

podman run -it --rm -d \
    --name maas-postgres \
    --env-file ${env_file} \
    -p 127.0.0.1:5432:5432 \
    docker.io/library/postgres:14-alpine
podman run -it --rm -d \
    --name maas \
    --net host \
    --env-file ${env_file} \
    --systemd=always \
    --privileged \
    --requires maas-postgres \
    maas:3.5

echo
echo
echo " ================> Exit logs to stop MAAS stack <================ "
echo 
echo

podman logs -f maas

echo
echo
echo " ================! Stopping MAAS stack !================ "
echo 
echo

podman rm -f maas
podman rm -f maas-postgres
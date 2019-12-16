#! /usr/bin/env bash

ENV="${ENV:-dev}"

# TODO prod support
if [ "$ENV" = "dev" ]; then
  if ! docker network ls | awk '{ print $2 }' | grep nginx-proxy_default; then
    echo "Creating nginx-proxy network"
    docker network create nginx-proxy_default
  fi
fi

docker-compose -f ./env/common/docker-compose.yml -f ./env/"$ENV"/docker-compose.yml "$@"

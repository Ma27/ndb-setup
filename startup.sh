#! /usr/bin/env bash

ENV="${ENV:-dev}"
echo -e "\e[33mUsing environment ${ENV@Q}...\e[0m"

check_dep() {
  if ! command -v "$1" >/dev/null; then
    echo -e "\e[31mPlease install $1 first!\e[0m"
    exit 1
  fi
}

bootstrap_dev() {
  if ! docker network ls | awk '{ print $2 }' | grep nginx-proxy_default >/dev/null; then
    echo "Creating nginx-proxy network"
    docker network create nginx-proxy_default
  fi
}

bootstrap_prod() {
  echo foo
}

check_dep docker-compose
check_dep docker

if [ "$#" -eq 0 ]; then
  echo -e "\e[31mNo command specified.\nThis is basically a wrapper for docker-compose. For further information please use --help.\e[0m"
  exit 1
fi

case "$ENV" in
  dev)
    bootstrap_dev
    ;;
  prod)
    bootstrap_prod
    ;;
  *)
    echo -e "\e[31mPlease specify either dev or prod as environment!\e[0m"
    exit 1
    ;;
esac

docker-compose -f ./env/common/docker-compose.yml -f ./env/"$ENV"/docker-compose.yml "$@"

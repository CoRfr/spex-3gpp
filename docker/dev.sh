#!/bin/sh

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

if docker ps | grep spex-app; then
  docker kill spex-app
  docker rm spex-app
fi

if ! docker ps -a | grep spex-mysql; then
  docker run \
    --name spex-mysql \
    -e DB_USER='spex'\
    -e DB_PASS='spex' \
    -e DB_NAME='spex' \
    -d \
    sameersbn/mysql:latest

  sleep 5
fi

TI=''
if [ -n "$1" ]; then
  TI="-ti"
fi

if docker ps -a | grep spex-app; then
  docker rm spex-app
fi

docker run \
  --name spex-app \
  --rm \
  -v /storage/web/specs:/home/app/webapp/specs \
  -v $DIR/database.yml:/home/app/webapp/config/database.yml \
  -v $DIR/webapp.sh:/etc/my_init.d/webapp.sh \
  --link spex-mysql:mysql \
  -p 127.0.0.1:3000:80 \
  $TI \
  corfr/spex $*


#!/bin/bash
set -e;

docker-ip() {
  docker inspect --format '{{ .NetworkSettings.IPAddress }}' "$@"
}

ID=$(docker ps | grep mongos1 |  awk '{print $1}')
if [[ -z "$ID" ]]; then
  sudo docker run \
  -P --name mongos1 \
  -d attachmentgenie/mongos \
  --port 27017 \
  --configdb $(docker-ip cfg1):27017,$(docker-ip cfg2):27017,$(docker-ip cfg3):27017
fi

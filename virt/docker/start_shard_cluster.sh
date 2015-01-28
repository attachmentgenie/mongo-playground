#!/bin/bash
set -e;

SHARDS=${1:2}

echo "$(SHARDS)"

docker-ip() {
  docker inspect --format '{{ .NetworkSettings.IPAddress }}' "$@"
}

docker-port() {
  docker port $@ 27017|cut -d ":" -f2
}

echo "Creating mongodb shard cluster."

if (( EUID != 0 )); then
  echo "You must have sudo permissions to do this."
  sudo -v
fi

IMAGE=$(sudo docker images | grep "attachmentgenie/mongodb " |  awk '{print $3}')
if [[ -z $IMAGE ]]; then
  echo "Creating image attachmentgenie/mongodb."
  sudo docker build -t attachmentgenie/mongodb mongod
fi

IMAGE=$(sudo docker images | grep "attachmentgenie/mongos " |  awk '{print $3}')
if [[ -z $IMAGE ]]; then
  echo "Creating image attachmentgenie/mongos."
  sudo docker build -t attachmentgenie/mongos mongos
fi

ID=$(docker ps | grep rs1_srv1 |  awk '{print $1}')
if [[ -z "$ID" ]]; then
  echo "Creating container rs1_srv1."
  sudo docker run \
  -P --name rs1_srv1 \
  -d attachmentgenie/mongodb \
  --replSet rs1 \
  --noprealloc --smallfiles
  attempt=0
  while [ $attempt -le 59 ]; do
    attempt=$(( $attempt + 1 ))
    echo "Waiting for server to be up (attempt: $attempt)..."
    result=$(docker logs rs1_srv1)
    if grep -q 'waiting for connections on port 27017' <<< $result ; then
      echo "Mongodb is up!"
      break
    fi
    sleep 2
  done
fi

ID=$(docker ps | grep rs1_srv2 |  awk '{print $1}')
if [[ -z "$ID" ]]; then
  echo "Creating container rs1_srv2."
  sudo docker run \
  -P --name rs1_srv2 \
  -d attachmentgenie/mongodb \
  --replSet rs1 \
  --noprealloc --smallfiles
  attempt=0
  while [ $attempt -le 59 ]; do
    attempt=$(( $attempt + 1 ))
    echo "Waiting for server to be up (attempt: $attempt)..."
    result=$(docker logs rs1_srv2)
    if grep -q 'waiting for connections on port 27017' <<< $result ; then
      echo "Mongodb is up!"
      break
    fi
    sleep 2
  done
fi

ID=$(docker ps | grep rs1_srv3 |  awk '{print $1}')
if [[ -z "$ID" ]]; then
  echo "Creating container rs1_srv3."
  sudo docker run \
  -P --name rs1_srv3 \
  -d attachmentgenie/mongodb \
  --replSet rs1 \
  --noprealloc --smallfiles
  attempt=0
  while [ $attempt -le 59 ]; do
    attempt=$(( $attempt + 1 ))
    echo "Waiting for server to be up (attempt: $attempt)..."
    result=$(docker logs rs1_srv3)
    if grep -q 'waiting for connections on port 27017' <<< $result ; then
      echo "Mongodb is up!"
      break
    fi
    sleep 2
  done
fi

echo "Creating rs1"
rm -f rs1.js
cat <<EOF > rs1.js
config = {_id: 'rs1', members: [
                      {_id: 0, host: '$(docker-ip rs1_srv1)'},
                      {_id: 1, host: '$(docker-ip rs1_srv2)'},
                      {_id: 2, host: '$(docker-ip rs1_srv3)'}]
}
rs.initiate(config);
EOF
mongo --port $(docker-port rs1_srv1) < rs1.js

ID=$(docker ps | grep rs2_srv1 |  awk '{print $1}')
if [[ -z "$ID" ]]; then
  echo "Creating container rs2_srv1."
  sudo docker run \
  -P --name rs2_srv1 \
  -d attachmentgenie/mongodb \
  --replSet rs2 \
  --noprealloc --smallfiles
  attempt=0
  while [ $attempt -le 59 ]; do
    attempt=$(( $attempt + 1 ))
    echo "Waiting for server to be up (attempt: $attempt)..."
    result=$(docker logs rs2_srv1)
    if grep -q 'waiting for connections on port 27017' <<< $result ; then
      echo "Mongodb is up!"
      break
    fi
    sleep 2
  done
fi

ID=$(docker ps | grep rs2_srv2 |  awk '{print $1}')
if [[ -z "$ID" ]]; then
  echo "Creating container rs2_srv2."
  sudo docker run \
  -P --name rs2_srv2 \
  -d attachmentgenie/mongodb \
  --replSet rs2 \
  --noprealloc --smallfiles
  attempt=0
  while [ $attempt -le 59 ]; do
    attempt=$(( $attempt + 1 ))
    echo "Waiting for server to be up (attempt: $attempt)..."
    result=$(docker logs rs2_srv2)
    if grep -q 'waiting for connections on port 27017' <<< $result ; then
      echo "Mongodb is up!"
      break
    fi
    sleep 2
  done
fi

ID=$(docker ps | grep rs2_srv3 |  awk '{print $1}')
if [[ -z "$ID" ]]; then
  echo "Creating container rs2_srv3."
  sudo docker run \
  -P --name rs2_srv3 \
  -d attachmentgenie/mongodb \
  --replSet rs2 \
  --noprealloc --smallfiles
  attempt=0
  while [ $attempt -le 59 ]; do
    attempt=$(( $attempt + 1 ))
    echo "Waiting for server to be up (attempt: $attempt)..."
    result=$(docker logs rs2_srv3)
    if grep -q 'waiting for connections on port 27017' <<< $result ; then
      echo "Mongodb is up!"
      break
    fi
    sleep 2
  done
fi

echo "Creating rs2"
rm -f rs2.js
cat <<EOF > rs2.js
config = {_id: 'rs2', members: [
{_id: 0, host: '$(docker-ip rs2_srv1)'},
{_id: 1, host: '$(docker-ip rs2_srv2)'},
{_id: 2, host: '$(docker-ip rs2_srv3)'}]
}
rs.initiate(config);
EOF
mongo --port $(docker-port rs2_srv1) < rs2.js

ID=$(docker ps | grep cfg1 |  awk '{print $1}')
if [[ -z "$ID" ]]; then
  echo "Creating container cfg1."
  sudo docker run \
  -P --name cfg1 \
  -d attachmentgenie/mongodb \
  --noprealloc --smallfiles \
  --configsvr \
  --dbpath /data/db \
  --port 27017
  attempt=0
  while [ $attempt -le 59 ]; do
    attempt=$(( $attempt + 1 ))
    echo "Waiting for server to be up (attempt: $attempt)..."
    result=$(docker logs cfg1)
    if grep -q 'waiting for connections on port 27017' <<< $result ; then
      echo "Mongodb is up!"
      break
    fi
    sleep 2
  done
fi

ID=$(docker ps | grep cfg2 |  awk '{print $1}')
if [[ -z "$ID" ]]; then
  echo "Creating container cfg2."
  sudo docker run \
  -P --name cfg2 \
  -d attachmentgenie/mongodb \
  --noprealloc --smallfiles \
  --configsvr \
  --dbpath /data/db \
  --port 27017
  attempt=0
  while [ $attempt -le 59 ]; do
    attempt=$(( $attempt + 1 ))
    echo "Waiting for server to be up (attempt: $attempt)..."
    result=$(docker logs cfg2)
    if grep -q 'waiting for connections on port 27017' <<< $result ; then
      echo "Mongodb is up!"
      break
    fi
    sleep 2
  done
fi

ID=$(docker ps | grep cfg3 |  awk '{print $1}')
if [[ -z "$ID" ]]; then
  echo "Creating container cfg3."
  sudo docker run \
  -P --name cfg3 \
  -d attachmentgenie/mongodb \
  --noprealloc --smallfiles \
  --configsvr \
  --dbpath /data/db \
  --port 27017
  attempt=0
  while [ $attempt -le 59 ]; do
    attempt=$(( $attempt + 1 ))
    echo "Waiting for server to be up (attempt: $attempt)..."
    result=$(docker logs cfg3)
    if grep -q 'waiting for connections on port 27017' <<< $result ; then
      echo "Mongodb is up!"
      break
    fi
    sleep 2
  done
fi

ID=$(docker ps | grep mongos1 |  awk '{print $1}')
if [[ -z "$ID" ]]; then
  echo "Creating container mongos1."
  sudo docker run \
  -P --name mongos1 \
  -d attachmentgenie/mongos \
  --port 27017 \
  --configdb $(docker-ip cfg1):27017,$(docker-ip cfg2):27017,$(docker-ip cfg3):27017
  attempt=0
  while [ $attempt -le 59 ]; do
    attempt=$(( $attempt + 1 ))
    echo "Waiting for server to be up (attempt: $attempt)..."
    result=$(docker logs mongos1)
    if grep -q 'waiting for connections on port 27017' <<< $result ; then
      echo "Mongodb is up!"
      break
    fi
    sleep 2
  done
fi

rm -f sh.js
cat <<EOF > sh.js
sh.addShard("rs1/$(docker-ip rs1_srv1):27017")
sh.addShard("rs2/$(docker-ip rs2_srv1):27017")
sh.status()
EOF
mongo --port $(docker-port mongos1) < sh.js

echo "MongoDB Cluster is now ready to use."
echo "Connect to cluster by:"
echo "$ mongo --port $(docker-port mongos1)"

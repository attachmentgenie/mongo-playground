#!/bin/bash
set -e;

docker-ip() {
  docker inspect --format '{{ .NetworkSettings.IPAddress }}' "$@"
}

docker-port() {
  docker port $@ 27017|cut -d ":" -f2
}

SHARDS=${1:-2}

echo "Creating Mongodb cluster with $SHARDS shards."

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
else
  echo "Container cfg1 exists."
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
else
  echo "Container cfg2 exists."
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
else
  echo "Container cfg3 exists."
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
else
  echo "Container mongos1 exists."
fi

for i in $(seq 1 $SHARDS)
do
  echo "Creating Shard ${i} of $SHARDS"
  ID=$(docker ps | grep rs${i}_srv1 |  awk '{print $1}')
  if [[ -z "$ID" ]]; then
    echo "Creating container rs${i}_srv1."
    sudo docker run \
    -P --name rs${i}_srv1 \
    -d attachmentgenie/mongodb \
    --replSet rs${i} \
    --noprealloc --smallfiles
    attempt=0
    while [ $attempt -le 59 ]; do
      attempt=$(( $attempt + 1 ))
      echo "Waiting for server to be up (attempt: $attempt)..."
      result=$(docker logs rs${i}_srv1)
      if grep -q 'waiting for connections on port 27017' <<< $result ; then
        echo "Mongodb is up!"
        break
      fi
      sleep 2
    done
  else
    echo "Container rs${i}_srv1 exists."
  fi

  ID=$(docker ps | grep rs${i}_srv2 |  awk '{print $1}')
  if [[ -z "$ID" ]]; then
    echo "Creating container rs${i}_srv2."
    sudo docker run \
    -P --name rs${i}_srv2 \
    -d attachmentgenie/mongodb \
    --replSet rs${i} \
    --noprealloc --smallfiles
    attempt=0
    while [ $attempt -le 59 ]; do
      attempt=$(( $attempt + 1 ))
      echo "Waiting for server to be up (attempt: $attempt)..."
      result=$(docker logs rs${i}_srv2)
      if grep -q 'waiting for connections on port 27017' <<< $result ; then
        echo "Mongodb is up!"
        break
      fi
      sleep 2
    done
  else
    echo "Container rs${i}_srv2 exists."
  fi

  ID=$(docker ps | grep rs${i}_srv3 |  awk '{print $1}')
  if [[ -z "$ID" ]]; then
    echo "Creating container rs${i}_srv3."
    sudo docker run \
    -P --name rs${i}_srv3 \
    -d attachmentgenie/mongodb \
    --replSet rs${i} \
    --noprealloc --smallfiles
    attempt=0
    while [ $attempt -le 59 ]; do
      attempt=$(( $attempt + 1 ))
      echo "Waiting for server to be up (attempt: $attempt)..."
      result=$(docker logs rs${i}_srv3)
      if grep -q 'waiting for connections on port 27017' <<< $result ; then
        echo "Mongodb is up!"
        break
      fi
      sleep 2
    done
  else
    echo "Container rs${i}_srv3 exists."
  fi

  echo "Creating rs${i}"
  rm -f rs${i}.js
cat <<EOF > rs${i}.js
  config = {_id: 'rs${i}', members: [
  {_id: 0, host: '$(docker-ip rs${i}_srv1)'},
  {_id: 1, host: '$(docker-ip rs${i}_srv2)'},
  {_id: 2, host: '$(docker-ip rs${i}_srv3)'}]
}
rs.initiate(config);
EOF
  mongo --port $(docker-port rs${i}_srv1) < rs${i}.js
  attempt=0
  while [ $attempt -le 59 ]; do
    attempt=$(( $attempt + 1 ))
    echo "Waiting for Replication set to be up (attempt: $attempt)..."
    result=$(mongo --port $(docker-port rs${i}_srv1) --eval "printjson(rs.status().ok)" | tail -1)
    if [ "$result" -eq "1" ]; then
      echo "Replication set is up!"
      break
    fi
    sleep 2
  done

  attempt=0
  while [ $attempt -le 59 ]; do
    attempt=$(( $attempt + 1 ))
    echo "Waiting for primary to be elected (attempt: $attempt)..."
    result=$(mongo --port $(docker-port rs${i}_srv1) --eval "printjson(rs.status().myState)" | tail -1)
    if [ "$result" -eq "1" ]; then
      echo "Election has taken place!"
      break
    fi
    sleep 2
  done

  echo "Adding rs${i} as shard to cluster."
  rm -f sh.js
cat <<EOF > rs${i}_sh.js
sh.addShard("rs${i}/$(docker-ip rs${i}_srv1):27017")
EOF
  mongo --port $(docker-port mongos1) < rs${i}_sh.js
done

echo "MongoDB Cluster is now ready to use."
echo "Connect to cluster by:"
echo "$ mongo --port $(docker-port mongos1)"

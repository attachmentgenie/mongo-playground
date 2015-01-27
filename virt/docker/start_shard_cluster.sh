#!/bin/bash
set -e;

docker-ip() {
  docker inspect --format '{{ .NetworkSettings.IPAddress }}' "$@"
}

echo "MongoDB Cluster is being setup."

if (( EUID != 0 )); then
  echo "You must have sudo permissions to do this."
  sudo -v
fi

IMAGE=$(sudo docker images | grep "attachmentgenie/mongodb " |  awk '{print $3}')
if [[ -z $IMAGE ]]; then
  sudo docker build -t attachmentgenie/mongodb mongod
fi

IMAGE=$(sudo docker images | grep "attachmentgenie/mongos " |  awk '{print $3}')
if [[ -z $IMAGE ]]; then
  sudo docker build -t attachmentgenie/mongos mongos
fi

ID=$(docker ps | grep rs1_srv1 |  awk '{print $1}')
if [[ -z "$ID" ]]; then
  sudo docker run \
  -P --name rs1_srv1 \
  -d attachmentgenie/mongodb \
  --replSet rs1 \
  --noprealloc --smallfiles
fi

ID=$(docker ps | grep rs1_srv2 |  awk '{print $1}')
if [[ -z "$ID" ]]; then
  sudo docker run \
  -P --name rs1_srv2 \
  -d attachmentgenie/mongodb \
  --replSet rs1 \
  --noprealloc --smallfiles
fi

ID=$(docker ps | grep rs1_srv3 |  awk '{print $1}')
if [[ -z "$ID" ]]; then
  sudo docker run \
  -P --name rs1_srv3 \
  -d attachmentgenie/mongodb \
  --replSet rs1 \
  --noprealloc --smallfiles
fi

echo "waiting 30s..."
sleep 30
rm -f rs1.js
cat <<EOF > rs1.js
rs.initiate()
EOF
mongo --port $(docker port rs1_srv1 27017|cut -d ":" -f2) < rs1.js

echo "waiting 30s..."
sleep 30
rm -f rs1conf.js
cat <<EOF > rs1conf.js
rs.add("$(docker-ip rs1_srv2):27017")
rs.add("$(docker-ip rs1_srv3):27017")
cfg = rs.conf()
cfg.members[0].host = "$(docker-ip rs1_srv1):27017"
rs.reconfig(cfg)
rs.status()
EOF
mongo --port $(docker port rs1_srv1 27017|cut -d ":" -f2) < rs1conf.js

ID=$(docker ps | grep rs2_srv1 |  awk '{print $1}')
if [[ -z "$ID" ]]; then
  sudo docker run \
  -P --name rs2_srv1 \
  -d attachmentgenie/mongodb \
  --replSet rs2 \
  --noprealloc --smallfiles
fi

ID=$(docker ps | grep rs2_srv2 |  awk '{print $1}')
if [[ -z "$ID" ]]; then
  sudo docker run \
  -P --name rs2_srv2 \
  -d attachmentgenie/mongodb \
  --replSet rs2 \
  --noprealloc --smallfiles
fi

ID=$(docker ps | grep rs2_srv3 |  awk '{print $1}')
if [[ -z "$ID" ]]; then
  sudo docker run \
  -P --name rs2_srv3 \
  -d attachmentgenie/mongodb \
  --replSet rs2 \
  --noprealloc --smallfiles
fi

echo "waiting 30s..."
sleep 30
rm -f rs2.js
cat <<EOF > rs2.js
rs.initiate()
EOF
mongo --port $(docker port rs2_srv1 27017|cut -d ":" -f2) < rs2.js

echo "waiting 30s..."
sleep 30
rm -f rs2conf.js
cat <<EOF > rs2conf.js
rs.add("$(docker-ip rs2_srv2):27017")
rs.add("$(docker-ip rs2_srv3):27017")
cfg = rs.conf()
cfg.members[0].host = "$(docker-ip rs2_srv1):27017"
rs.reconfig(cfg)
rs.status()
EOF
mongo --port $(docker port rs2_srv1 27017|cut -d ":" -f2) < rs2conf.js

ID=$(docker ps | grep cfg1 |  awk '{print $1}')
if [[ -z "$ID" ]]; then
  sudo docker run \
  -P --name cfg1 \
  -d attachmentgenie/mongodb \
  --noprealloc --smallfiles \
  --configsvr \
  --dbpath /data/db \
  --port 27017
fi

ID=$(docker ps | grep cfg2 |  awk '{print $1}')
if [[ -z "$ID" ]]; then
  sudo docker run \
  -P --name cfg2 \
  -d attachmentgenie/mongodb \
  --noprealloc --smallfiles \
  --configsvr \
  --dbpath /data/db \
  --port 27017
fi

ID=$(docker ps | grep cfg3 |  awk '{print $1}')
if [[ -z "$ID" ]]; then
  sudo docker run \
  -P --name cfg3 \
  -d attachmentgenie/mongodb \
  --noprealloc --smallfiles \
  --configsvr \
  --dbpath /data/db \
  --port 27017
fi

echo "waiting 60s..."
sleep 60
ID=$(docker ps | grep mongos1 |  awk '{print $1}')
if [[ -z "$ID" ]]; then
  sudo docker run \
  -P --name mongos1 \
  -d attachmentgenie/mongos \
  --port 27017 \
  --configdb $(docker-ip cfg1):27017,$(docker-ip cfg2):27017,$(docker-ip cfg3):27017
fi

echo "waiting 60s..."
sleep 60
rm -f sh.js
cat <<EOF > sh.js
sh.addShard("rs1/$(docker-ip rs1_srv1):27017")
sh.addShard("rs2/$(docker-ip rs2_srv1):27017")
sh.status()
EOF
mongo --port $(docker port mongos1 27017|cut -d ":" -f2) < sh.js

echo "MongoDB Cluster is now ready to use."
echo "Connect to cluster by:"
echo "$ mongo --port $(docker port mongos1 27017|cut -d ":" -f2)"

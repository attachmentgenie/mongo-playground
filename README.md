# Mongo Playground

A basic Ubuntu 14.04 virtual machine that can be useful when experimenting with mongdb setups.
The box includes a basic mongo installation, nodejs, php, python and ruby language bindings
as well as bootstrap scripts to quickly start a replication set or a sharded cluster using docker.

## Connect to mongo server in vagrant box

``` bash
mongo
```

## Start a replication set using docker

``` bash
[vagrant@playground ~]$ cd testbench/bin/
[vagrant@playground bin]$ ./start_replset.sh
Creating Mongodb Replication Set.
You must have sudo permissions to do this.
MongoDB Replication Set name : rs1
Creating MongoDB Replication Set named rs1.
.....
MongoDB Replication Set is now ready to use
{
  "set" : "rs1",
  "date" : ISODate("2015-01-29T11:56:53Z"),
  "myState" : 1,
  "members" : [
  {
    "_id" : 0,
    "name" : "172.17.0.37:27017",
    "health" : 1,
    "state" : 1,
    "stateStr" : "PRIMARY",
    "uptime" : 935,
    "optime" : Timestamp(1422531740, 1),
    "optimeDate" : ISODate("2015-01-29T11:42:20Z"),
    "self" : true
  },
  {
    "_id" : 1,
    "name" : "172.17.0.38:27017",
    "health" : 1,
    "state" : 2,
    "stateStr" : "SECONDARY",
    "uptime" : 869,
    "optime" : Timestamp(1422531740, 1),
    "optimeDate" : ISODate("2015-01-29T11:42:20Z"),
    "lastHeartbeat" : ISODate("2015-01-29T11:56:51Z"),
    "lastHeartbeatRecv" : ISODate("2015-01-29T11:56:51Z"),
    "pingMs" : 1,
    "syncingTo" : "172.17.0.37:27017"
  },
  {
    "_id" : 2,
    "name" : "172.17.0.39:27017",
    "health" : 1,
    "state" : 2,
    "stateStr" : "SECONDARY",
    "uptime" : 869,
    "optime" : Timestamp(1422531740, 1),
    "optimeDate" : ISODate("2015-01-29T11:42:20Z"),
    "lastHeartbeat" : ISODate("2015-01-29T11:56:51Z"),
    "lastHeartbeatRecv" : ISODate("2015-01-29T11:56:51Z"),
    "pingMs" : 1,
    "syncingTo" : "172.17.0.37:27017"
  }
  ],
  "ok" : 1
}
Connect to MongoDB Replication Set by:
$ mongo --port 49178
```

## Start a sharded cluster using docker

``` bash
[vagrant@playground ~]$ cd testbench/bin/
[vagrant@playground bin]$ ./start_shard_cluster.sh
How many shards do you want to create : 3
Creating Mongodb cluster with 3 shards.
.....
MongoDB Cluster is now ready to use
--- Sharding Status ---
sharding version: {
  "_id" : 1,
  "version" : 3,
  "minCompatibleVersion" : 3,
  "currentVersion" : 4,
  "clusterId" : ObjectId("54c9f4c2ba2b390c0a2d1b5c")
}
shards:
{  "_id" : "rs1",  "host" : "rs1/172.17.0.132:27017,172.17.0.133:27017,172.17.0.134:27017" }
{  "_id" : "rs2",  "host" : "rs2/172.17.0.135:27017,172.17.0.136:27017,172.17.0.137:27017" }
{  "_id" : "rs3",  "host" : "rs3/172.17.0.138:27017,172.17.0.139:27017,172.17.0.140:27017" }
databases:
{  "_id" : "admin",  "partitioned" : false,  "primary" : "config" }

Connect to cluster by:
$ mongo --port 49282
```

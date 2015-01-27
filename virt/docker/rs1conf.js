rs.add("172.17.0.155:27017")
rs.add("172.17.0.156:27017")
cfg = rs.conf()
cfg.members[0].host = "172.17.0.154:27017"
rs.reconfig(cfg)
rs.status()

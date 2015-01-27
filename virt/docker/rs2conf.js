rs.add("172.17.0.158:27017")
rs.add("172.17.0.159:27017")
cfg = rs.conf()
cfg.members[0].host = "172.17.0.157:27017"
rs.reconfig(cfg)
rs.status()

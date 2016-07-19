# example to use this project with server instead of vagrant vm
# you can put the messy ssh_options in ~/.ssh/config
server :hpms, roles: :hive, user: :ubuntu
set :port_forwarding_template,
   "ssh hpms -L 2233:container_ip:22 -L 8888:container_ip:80 -N"

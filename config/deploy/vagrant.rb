server :localhost,
  roles: :hive,
  user: :ubuntu,
  ssh_options: {
    keys: '.vagrant/machines/default/virtualbox/private_key',
    forward_agent: false,
    auth_methods: %w(publickey),
    port: 2222
  }
set :port_forwarding_template,
   "ssh ubuntu@localhost -p 2222 -i .vagrant/machines/default/virtualbox/private_key -L 2233:container_ip:22 -L 8888:container_ip:80 -N"

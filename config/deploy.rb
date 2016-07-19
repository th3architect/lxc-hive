lock '3.5.0'
set :log_level, :debug

# lxc hive related

set :default_profile, 'default'
set :base_image, 'ubuntu:14.04'
set :ip_reg, /10\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/

# if the container OS is not ubuntu, then you need to change this
set :container_authorized_keys_file, '/home/ubuntu/.ssh/authorized_keys'

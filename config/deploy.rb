lock '3.5.0'
set :log_level, :debug

# lxc hive related

set :default_profile, 'default'
set :base_image, 'ubuntu:14.04'
set :base_container, 'prototype'
set :base_snapshot, 'snap'
set :ip_reg, /10\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/

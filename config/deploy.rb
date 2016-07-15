lock '3.5.0'
set :log_level, :debug

# lxc hive related

set :port_source, [22, 80]
set :port_target, [2222, 8888]
set :base_image, 'ubuntu:14.04'

require_relative '../hive_helper'
include HiveHelper

desc 'lxc commands'
namespace :lxc do

  desc 'get info about container'
  task :info, :container do |t, args|
    container = HiveHelper::fetch_arg(args, :container)
    info = HiveHelper::container_info(container)
    if info.nil?
      puts "#{container} not found!"
    else
      puts info
    end
  end

  desc 'start the container'
  task :start, :container do |t, args|
    HiveHelper::set_args(args)
    HiveHelper::start
  end

  desc 'stop the container'
  task :stop, :container do |t, args|
    HiveHelper::set_args(args)
    HiveHelper::stop
  end

  desc 'launch the container'
  task :launch, :container, :image do |t, args|
    HiveHelper::set_args(args)
    HiveHelper::launch
  end

  desc 'create container from snapshot'
  task :copy, :container, :source_container, :snapshot do |t,args|
    HiveHelper::set_args(args)
    HiveHelper::copy
  end

  desc 'create a snapshot of a container'
  task :snapshot, :container, :snapshot do |t, args|
    HiveHelper::set_args(args)
    HiveHelper::take_snapshot
  end

  desc 'restore a container to the state of a snapshot'
  task :restore, :container, :snapshot do |t, args|
    HiveHelper::set_args(args)
    HiveHelper::restore
  end

  desc 'delete a container'
  task :delete, :container do |t, args|
    HiveHelper::set_args(args)
    HiveHelper::delete
  end

  desc 'build: provision container based on profile'
  task :build, :container, :profile do |t, args|
    HiveHelper::set_args(args)
    HiveHelper::build
  end

  desc 'build the prototype for other containers'
  task :build_profile, :profile do |t, args|
    HiveHelper::set_args(args)
    prototype = HiveHelper::profile + '-proto'
    invoke('lxc:stop', prototype) rescue ' '
    invoke('lxc:delete', prototype) rescue ' '
    invoke('lxc:launch', prototype)
    HiveHelper::wait_connection(prototype)
    invoke('lxc:build',prototype, profile)
    invoke('lxc:snapshot', prototype, 'snap')
    invoke('lxc:stop', prototype)
  end

end

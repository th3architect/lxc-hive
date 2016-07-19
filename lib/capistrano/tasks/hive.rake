# A user-friendly list of tasks.
# Always ask politely.

require_relative '../hive_helper'
include HiveHelper
require 'byebug'

desc "hive:build profile"
task :build, :profile do |t, args|
  profile = args[:profile] || HiveHelper::select_profile
  invoke('lxc:build_profile', profile)
end

desc "hive:create / start a container"
task :up, :container, :profile do |t, args|
  container = args[:container] || HiveHelper::ask_container_name
  if HiveHelper::container_exist?(container)
    invoke('lxc:start', container)
    next
  end
  profile = args[:profile] || HiveHelper::select_profile
  unless HiveHelper::profile_built?(profile)
    raise "You need to build the profile first."
  end
  invoke('lxc:copy', container, HiveHelper::profile_container(profile), "snap")
  invoke('lxc:start', container)
end

desc "hive:stop a container"
task :stop, :container do |t, args|
  container = args[:container] || HiveHelper::select_container
  invoke('lxc:stop', container) unless container.nil?
end

desc "hive:task a snapshot"
task :snapshot, :container, :snapshot do |t, args|
  container = args[:container] || HiveHelper::select_container
  snapshot = args[:snapshot] || HiveHelper::ask_snapshot_name
  invoke('lxc:snapshot', container, snapshot) unless container.nil?
end

desc "hive:restore to the latest snapshot"
task :restore, :container, :snapshot do |t, args|
  container = args[:container] || HiveHelper::select_container
  snapshot = args[:snapshot] || HiveHelper::ask_snapshot_name
  invoke('lxc:restore', container, snapshot) unless container.nil?
end

desc "hive:delete the container"
task :delete, :container do |t, args|
  container = args[:container] || HiveHelper::select_container
  invoke('lxc:delete', container) unless container.nil?
end

desc "hive:forwarding ports for container"
task :forward, :container do |t, args|
  container = args[:container] || HiveHelper::select_container
  forwarding_cmd = HiveHelper::forwarding_cmd(container)
  puts "forward ports for #{container}:"
  puts forwarding_cmd
  %x{#{forwarding_cmd}}
end

desc "hive:list containers"
task :list do
  on roles(:hive) do
    execute 'lxc list'
  end
end

# from https://github.com/capistrano/capistrano/blob/master/lib/capistrano/tasks/console.rake
desc "hive:Execute remote commands"
task :console, :container do |t, args|
  container = args[:container] || HiveHelper::select_container
  loop do
    print "#{container}> "

    command = (input = $stdin.gets) ? input.chomp : "exit"

    next if command.empty?

    if %w{quit exit q}.include? command
      puts t("console.bye")
      break
    else
      begin
        on roles :hive do
          execute :lxc, :exec, container, '--', command
        end
      rescue => e
        puts e
      end
    end
  end
end


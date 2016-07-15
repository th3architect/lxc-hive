require_relative '../hive_helper'
include HiveHelper

desc 'lxc commands'
namespace :lxc do

  %w(start info stop build create_image create_container delete_image delete_container test).each do |cmd|
    desc "#{cmd} a container"
    task cmd.to_sym, :name, :image do |t, args|
      on roles(:hive) do
        name = HiveHelper::value_from_argument(args, :name)
        case cmd
        when 'start', 'stop', 'info'
          raise "Container does not exist" unless HiveHelper::has_container?(self, name)
          case cmd
          when 'start'
            raise "Container already running" if HiveHelper::container_running?(self, name)
          when 'stop'
            raise "Container already stopped" unless HiveHelper::container_running?(self, name)
          end
          execute :lxc, cmd, name
        when 'build'
          HiveHelper::public_key_ready!
          raise "Container does not exist" unless HiveHelper::has_container?(self, name)
          invoke 'lxc:start' unless HiveHelper::container_running?(self, name)
          tasks = [
            {
              source: 'bootstrap/init.sh',
              target: '/root/init.sh'
            },{
              source: 'bootstrap/setup.pp',
              target: '/root/setup.pp'
            }
          ]
          HiveHelper::upload_run_and_clean(self, name,tasks) do |context,name|
            context.execute :lxc, :exec, name, '--', :chmod, '+x', '/root/init.sh'
            context.execute :lxc, :exec, name, '--', '/root/init.sh'
          end
        when 'create_image'
          running = is_container_running(name)
          invoke('lxc:stop', name) if running
          execute "lxc publish #{name} --alias #{image}"
          puts "  #{image} ->"
          puts "  "+ capture("lxc image list | grep #{image}")
          invoke('lxc:start', name) if running
        else
          raise "task not implemented"
        end
      end
    end
  end

end

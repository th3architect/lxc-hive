require_relative '../hive_helper'
include HiveHelper

desc 'lxc commands'
namespace :lxc do

  %w(start info stop delete build create_image create_container delete_image delete_container test image_info).each do |cmd|
    desc "#{cmd} a #{cmd.include?('image') ? 'image' : 'container'}"
    task cmd.to_sym, :name, :image do |t, args|
      on roles(:hive) do
        name = HiveHelper::value_from_argument(args, :name)
        case cmd
        when 'start', 'stop', 'info', 'delete'
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
          image = HiveHelper::value_from_argument(args, :image)
          raise "image #{image} already exists" if HiveHelper::has_image?(self, image)
          raise "Container does not exist" unless HiveHelper::has_container?(self, name)
          running = HiveHelper::container_running?(self, name)
          warn "the container will be offline when the image is being created"
          invoke('lxc:stop', name) if running
          execute :lxc, :publish, name, '--alias', image
          invoke('lxc:start', name) if running
          invoke('lxc:image_info', image)
        when 'create_container'
          image = HiveHelper::value_from_argument(args, :image, default: 'ubuntu:14.04')
          raise "image #{image} does not exists" unless HiveHelper::has_image?(self, image)
          raise "Container already exists" if HiveHelper::has_container?(self, name)
          execute :lxc, :launch, image, name
          invoke('lxc:info', name)
        when 'image_info'
          image = name
          puts "\n" + "="*10 + "info @ image #{image}" + "="*10
          puts capture("lxc image info #{image}")
          puts "="*10 + "info @ image #{image}" + "="*10 + "\n"
        else
          raise "task not implemented"
        end
      end
    end
  end

end

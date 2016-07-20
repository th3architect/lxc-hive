module HiveHelper
  @@context = nil
  @@info = {}

  # variables
  def context
    if @@context.nil?
      on roles(:hive) do
        @@context = self
      end
    end
    return @@context
  end

  def set_args(args)
    @@args = args
  end
  def args
    @@args
  end

  def container
    fetch_arg(args, :container)
  end
  def snapshot
    fetch_arg(args, :snapshot)
  end
  def source_container
    fetch_arg(args, :source_container)
  end
  def image
    fetch_arg(args, :image, default: fetch(:base_image))
  end
  def profile
    fetch_arg(args, :profile, default: fetch(:default_profile))
  end
  def container_ip(container)
    matches = container_info(container).match(fetch(:ip_reg))
    return nil if matches.nil?
    return matches[0]
  end
  def profile_container(profile)
    profile + '-proto'
  end

  # utilities
  def container_info(container)
    @@info[container] ||= context.capture(%{lxc info #{container}}) rescue ''
  end

  def container_exist?(container)
    not container_info(container).empty?
  end

  def container_running?(container)
    container_info(container).include?('Status: Running')
  end
  def container_has_snapshot?(container, snapshot)
    container_info(container).include?(%{  #{snapshot} (taken at})
  end

  def wait_connection(container)
    while(context.capture("lxc info #{container}").match(fetch(:ip_reg)).nil?)
      # to setup connection
      # context.execute("lxc exec #{container} curl google.com") rescue ''
      puts "it seems that the container is not connected yet."
      %x{sleep 1}
    end
    %x{sleep 5}
  end
  def forwarding_cmd(container)
    ip = container_ip(container)
    template = fetch( :port_forwarding_template)
    raise "port_forwarding_template not set" if template.nil?
    template.gsub('container_ip', ip)
  end
  def profile_built?(profile)
    container_exist?(profile_container(profile))
  end
  def profile_list
    puts %x{ls ./profiles/}
  end
  def container_list
    puts context.capture(%{lxc list})
  end
  def select_container
    puts "List of Containers"
    container_list
    set :tempvalue, ask("\nthe name of the container:\n")
    return fetch(:tempvalue)
  end
  def select_profile
    puts "List of Profiles"
    profile_list
    set :tempvalue, ask("\nthe name of the profile:\n")
    return fetch(:tempvalue)
  end
  def ask_container_name
    set :tempvalue, ask("\nThe container need a name\n")
    return fetch(:tempvalue)
  end
  def ask_snapshot_name
    set :tempvalue, ask("\nThe snapshot need a name\n")
    return fetch(:tempvalue)
  end

  def fetch_arg(args, key, default: nil)
    val = args[key] || default
    raise "You need to specify #{key}" if val.nil?
    return val
  end

  # actions
  def start
    context.execute %{lxc start #{container}}
  end
  def stop
    context.execute %{lxc stop #{container}}
  end
  def launch
    context.execute %{lxc launch #{image} #{container}}
  end
  def copy
    context.execute %{lxc copy #{source_container}/#{snapshot} #{container}}
  end
  def take_snapshot
    context.execute %{lxc snapshot #{container} #{snapshot}}
  end
  def restore
    context.execute %{lxc restore #{container} #{snapshot}}
  end
  def delete
    context.execute %{lxc delete #{container}}
  end
  def build
    add_public_key
    apply_profile
  end
  def add_public_key
    context.execute %{lxc file push ~/.ssh/authorized_keys #{container}#{fetch(:container_authorized_keys_file)}}
  end
  def apply_profile
    zipfile = 'profile_lxc_hive.tar.gz'
    zipfile_temp = '/tmp/'+zipfile
    # upload
    %x{tar czf #{zipfile} ./profiles/#{profile}}
    context.upload! zipfile, zipfile_temp, force: true, via: :scp
    context.execute :lxc, :file, :push, zipfile_temp, container + '/' + zipfile_temp
    context.execute :lxc, :exec, container, '--', :tar, :xzf, zipfile_temp
    # execute
    profile_root = '/root/profiles/' + profile + '/'
    context.execute :lxc, :exec, container, '--', :chmod, '+x', profile_root + 'init.sh'
    context.execute :lxc, :exec, container, '--', profile_root + 'init.sh ' + profile_root
    # clean
    %x{rm #{zipfile}}
    context.execute :rm, zipfile_temp
    context.execute :lxc, :exec, container, '--', 'rm ' + zipfile_temp
    context.execute :lxc, :exec, container, '--', 'rm -r ' + '/root/profiles'
  end

  def yes_or_no(question, default: 'yes')
    set :tempvalue_question_1, ask("\n" + question + "y(es)/n(o)", default)
    return fetch(:tempvalue_question_1).include?('y')
  end

end

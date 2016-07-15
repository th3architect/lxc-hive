module HiveHelper

  def value_from_argument(args, key, required: true, default: nil)
    val = args[key] || default
    raise "You need to specify #{key}" if val.nil? and required
    return val
  end
  def public_key_ready!
    line_public_key = %x{cat bootstrap/setup.pp | grep 'ssh_pub_key ='}
    unless line_public_key.size > 40
      puts ""
      puts "="*20 + " important" + "="*20
      puts "You need to set ssh_pub_key in this file:"
      puts "./bootstrap/setup.pp"
      puts "This is required so that you can access the container with the ssh key"
      puts "note: you may also want to change the user @ line 3"
      puts "="*20 + " important" + "="*20
      puts ""
      raise "ssh_pub_key not specified"
    end
  end

  def has_container?(context, container_name)
    context.test("lxc info #{container_name}")
  end
  def has_image?(context, image_name)
    context.test("lxc image info #{image_name}")
  end
  def container_running?(context, container_name)
    context.capture("lxc info #{container_name}").include?('Status: Running')
  end

  def upload_run_and_clean(context, container_name, upload_tasks)
    upload(context, container_name, upload_tasks)
    yield(context, container_name)
    remove_uploads(context, container_name ,upload_tasks)
  end

  def upload(context, container_name, upload_tasks)
    midway = '/tmp/lxc-hive-tempfolder'
    context.execute :mkdir, '-p', midway
    upload_tasks.each do |task|
      tempfile = "#{midway}/#{task[:target].split('/').last}"
      context.upload! task[:source], tempfile, force: true, via: :scp
      context.execute :lxc, :file, :push, tempfile, "#{container_name}/#{task[:target]}"
    end
    context.execute :rm, '-r', midway
  end

  def remove_uploads(context, container_name, upload_tasks)
    upload_tasks.each do |task|
      context.execute :lxc, :exec, container_name, :rm, task[:target]
    end
  end

end

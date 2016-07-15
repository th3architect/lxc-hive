# variables

$user = "lxcadmin"
$ssh_pub_key = ""

# main
class { 'sudo':
  purge               => false,
  config_file_replace => false,
}

define useradd ( $sshkey ) {

  $username = $title

  user { "$username":
    comment    => "$username",
    home       => "/home/$username",
    shell      => "/bin/bash",
    managehome => "true",
    password   => "*",
  }

  ssh_authorized_key { "default-ssh-key-for-$username":
    user   => "$username",
    ensure => present,
    type   => "ssh-rsa",
    key    => "$sshkey",
  }

}

useradd{"$user":
  sshkey => $ssh_pub_key
}

sudo::conf { "$user":
  content  => "$user ALL=(ALL) NOPASSWD: ALL",
}

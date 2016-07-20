class { 'nginx': }

file { '/etc/nginx/sites-available/hive':
  owner => root,
  group => root,
  mode  => 644,
  content => "server {listen 80; server_name _; location / {return 200 'lxc hive'; add_header Content-Type text/plain;}}"
}
file { '/etc/nginx/sites-enabled/hive':
  ensure => 'link',
  target => '/etc/nginx/sites-available/hive',
  notify  => Service['nginx']
}

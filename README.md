# LXD Hive: manage a swarm of lxc in vm or server

This is a Capistrano 3 based tool to control and provision Linux Containers nested in a vagrant-managed virtualbox VM. The idea is that managing containers instead of VMs is way **faster**. After taking some time to create the environment, everything that follows takes about a second each.

## Features

- create, provision, destroy, duplicate lxc instances
- port forwarding with *ssh*
- work with both server and vm.

## Install

- install Ruby 2.0 or newer
- clone this repository
- run `bundle install` in the folder
- install vagrant and virtualbox

## Quick Start
1. `vagrant up` - start the vagrant machine. While the project works for server, vagrant managed virtualbox is a good starting point. The vagrant file provided creates a confortable environment for lxc.
2. `cap -T | grep hive` - list of tasks that you can try.
3. `cap vagrant build[default]` - first, we need to build a profile. Profile is used to provision your containers.
4. `cap vagrant up[t1,default]` - create container t1 based on a profile.
5. `cap vagrant console[t1]` - start a console session.
5. `cap vagrant forward[t1]` - forward ports so that you can access them on your local machine. access your container @ `ssh ubuntu@localhost -p 2233 -i .vagrant/machines/default/virtualbox/private_key`
6. `cap vagrant snapshot[t1,step1]` - create a snapshot named step1.
7. `cap vagrant restore[t1,step1]` - restore your container to step1. Note that you can only restore to the latest snapshot.
8. `cap vagrant stop[t1]` - stop the container.

## Integrate into your system

### call from anywhere

add this to your command:

```
#! /usr/bin/env bash

cd ~/lxc-hive
target="vagrant"

if [ "$#" -eq 0 ]; then
  echo "action not specified"
elif [ "$#" -eq 1 ]; then
  # hive list
  # hive up[t1]
  cap "$target" "$@"
elif [ "$#" -eq 2 ]; then
  # hive up t1
  cap "$target" "$1[$2]"
elif [ "$#" -eq 3 ]; then
  # hive up t1 default
  cap "$target" "$1[$2,$3]"
fi
```

### ssh config

add this to ~/.ssh/config:

```
Host vagrant
  HostName localhost
  User ubuntu
  Port 2222
  UserKnownHostsFile /dev/null
  StrictHostKeyChecking no
  PasswordAuthentication no
  IdentityFile ~/lxc-hive/.vagrant/machines/default/virtualbox/private_key
  IdentitiesOnly yes
  LogLevel FATAL
Host lxc
  HostName localhost
  User ubuntu
  Port 2233
  UserKnownHostsFile /dev/null
  StrictHostKeyChecking no
  PasswordAuthentication no
  IdentityFile ~/lxc-hive/.vagrant/machines/default/virtualbox/private_key
  IdentitiesOnly yes
  LogLevel FATAL
```

## Notes

### Use with server instead of vm
create a capistrano stage file in `./config/deploy`.

### What is a profile

A profile is used to provision your container. You can create your own profile inside `./profiles` folder. Check out `default` and `puppet` profiles as a starting point. Each profile should have a `init.sh` at its root directory.

### What does `build` do

For example, `cap vagrant build[default]`:

1. create a prototype container and start it.
2. copy the server's `authorized_keys` to the container
3. copy the default profile to the container
4. run `init.sh` inside the container
5. make a snapshot and stop the container

### What does `up` do

For example, `cap vagrant up[t1,default]`:

if t1 already exists, then it tries to start the container, else ->

1. make sure the profile is specified and a prototype container exists.
2. copy from prototype container's snapshot and create a container

### why not just use vagrant

LXC is fast:

```
wj:~/lxc-hive:#cap vagrant up[t1,default]
00:00 lxc:copy
      01 lxc copy default-proto/snap t1
    ✔ 01 ubuntu@localhost 0.157s
00:00 lxc:start
      01 lxc start t1
    ✔ 01 ubuntu@localhost 0.292s
wj:~/lxc-hive:#cap vagrant snapshot[t1,step1]
00:00 lxc:snapshot
      01 lxc snapshot t1 step1
    ✔ 01 ubuntu@localhost 0.243s
wj:~/lxc-hive:#cap vagrant restore[t1,step1]
00:00 lxc:restore
      01 lxc restore t1 step1
    ✔ 01 ubuntu@localhost 2.234s
wj:~/lxc-hive:#cap vagrant stop[t1]
00:00 lxc:stop
      01 lxc stop t1
    ✔ 01 ubuntu@localhost 1.101s
wj:~/lxc-hive:#cap vagrant up[t1]
00:00 lxc:start
      01 lxc start t1
    ✔ 01 ubuntu@localhost 0.457s
```

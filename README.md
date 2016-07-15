# LXD Hive: Manage LXC instances with puppet and capistrano

This is a Capistrano 3 based tool to control and provision Linux Containers. The project tries to make it easy to enjoy the fantastic speed of LXD. You may need to be familiar with Capistrano.


## Features

- create, provision, destroy, duplicate lxc instances
- port forwarding with *ssh*

## Requirements

- a recent version of ruby
- lxd installed on a remote server (or a virtual machine) [guide](https://linuxcontainers.org/lxd/getting-started-cli/)

## Install

- clone this repository
- run `bundle install` in the folder

## config

- use Capistrano stage file to define how to connect to your server.
- edit this file to set a name and a ssh_pub_key so that you can ssh into the container: `bootstrap/setup.pp`. Note that the ssh_pub_key does not allow spaces in the string.

## Quick Start

1. `cap -T` to see the list of available tasks.
2. create configuration file for your server, an example can be found at *config/deploy/hive.rb.sample*.
3. `cap server up[lxc1]` to launch a container named *lxc1*.
4. `cap server connect[lxc1]` to forward port with ssh. By default, you can ssh to the *lxc1* instance @ 2222 and access http @ 8888.

## Advanced

- You can edit files in *bootstrap* folder to reflect your provision strategy.
- `cap server image[lxc1,image1]` creates an image named *image1* from container *lxc1*. (note: the container will be offline when the image is being created.)
- `cap server up[lxc2,image1]` creates a new container *lxc2* from image *image1*


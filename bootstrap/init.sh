#!/bin/bash

sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get install puppet -y
sudo puppet module install saz-sudo
sudo puppet apply /root/setup.pp

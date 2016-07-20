#!/bin/bash

# go to current folder
cd $1

# run some provision scripts
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get install puppet -y
sudo puppet module install jfryman-nginx
sudo puppet apply ./site.pp

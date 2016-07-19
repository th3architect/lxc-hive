#!/bin/bash

# go to current folder
cd $1

# run some provision scripts
sudo apt-get update -y
sudo apt-get upgrade -y
cp ./note.md /root/

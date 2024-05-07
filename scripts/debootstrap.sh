#!/bin/bash

pushd $1
sudo mkdir debian
sudo debootstrap --arch=arm64 --foreign $2 debian http://deb.debian.org/debian/ /usr/share/debootstrap/scripts/$2
popd
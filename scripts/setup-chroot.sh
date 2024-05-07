#!/bin/bash

pushd $1
echo "nameserver 8.8.8.8" | sudo tee debian/etc/resolv.conf
sudo mount --make-rslave --rbind /proc debian/proc
sudo mount --make-rslave --rbind /sys debian/sys
sudo mount --make-rslave --rbind /dev debian/dev
sudo mount --make-rslave --rbind /run debian/run
sudo cp "$(which qemu-aarch64-static)" debian/usr/bin
popd
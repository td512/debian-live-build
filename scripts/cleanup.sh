#!/bin/bash

pushd $1
sudo rm -f debian/usr/bin/qemu-aarch64-static
sudo umount -lf debian/proc
sudo umount -lf debian/sys
sudo umount -lf debian/dev
sudo umount -lf debian/run
popd
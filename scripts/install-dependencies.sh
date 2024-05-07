#!/bin/bash

sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get install qemu-user-static debootstrap qemu-utils qemu-efi-aarch64 qemu-system-arm xz-utils -y
sudo docker run --privileged --rm tonistiigi/binfmt --install all
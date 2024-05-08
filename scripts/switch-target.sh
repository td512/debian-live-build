#!/bin/bash

pushd $1
chroot debian systemctl set-default $2.target
popd

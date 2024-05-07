#!/bin/bash

pushd $1
sudo chroot debian /debootstrap/debootstrap --second-stage
popd
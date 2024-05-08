#!/bin/bash

pushd $1
sudo chroot debian apt-get install -y plymouth
sudo chroot debian tasksel install $2-desktop
popd

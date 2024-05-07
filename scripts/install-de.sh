#!/bin/bash

sudo chroot debian apt-get install -y plymouth
sudo chroot debian tasksel install $1-desktop

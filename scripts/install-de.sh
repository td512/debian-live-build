#!/bin/bash

apt-get install -y plymouth
tasksel install $1-desktop --new-install

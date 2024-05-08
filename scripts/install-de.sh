#!/bin/bash

apt-get install -y plymouth
DESKTOP=$(echo "$2-desktop" | tr -d " \t\n\r") 
tasksel install $DESKTOP --new-install

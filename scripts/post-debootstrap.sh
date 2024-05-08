#!/bin/bash

cat <<EOT > /etc/apt/sources.list
deb http://deb.debian.org/debian/ $1 main contrib non-free
deb-src http://deb.debian.org/debian/ $1 main contrib non-free
deb http://deb.debian.org/debian/ $1-updates main contrib non-free
deb-src http://deb.debian.org/debian/ $1-updates main contrib non-free
deb http://security.debian.org/debian-security $1-security main contrib non-free
deb-src http://security.debian.org/debian-security $1-security main contrib non-free
deb http://deb.debian.org/debian/ $1-backports main contrib non-free
deb-src http://deb.debian.org/debian/ $1-backports main contrib non-free
EOT
apt-get update
apt-get install locales dialog tzdata u-boot-menu -y
echo "Etc/GMT" > /etc/timezone
sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
echo 'LANG="en_US.UTF-8"'>/etc/default/locale
dpkg-reconfigure --frontend=noninteractive locales && \
update-locale LANG=en_US.UTF-8
env LANG en_US.UTF-8
env LANGUAGE en_US.UTF-8
env LC_ALL en_US.UTF-8
useradd -m -s /bin/bash debian
usermod -aG sudo debian
echo 'debian:debian'|chpasswd
apt-get install vim openssh-server ntpdate sudo ifupdown net-tools udev iputils-ping wget dosfstools unzip binutils libatomic1 -y
systemctl enable ssh
cat <<EOT > /etc/network/interfaces
allow-hotplug eth0
iface eth0 inet dhcp
EOT
#!/bin/bash

set -ex

# update packages
apt-get update
apt-get upgrade -y
apt-get install -y u-boot-menu 

# Let systemd create machine id on first boot
rm -f /var/lib/dbus/machine-id
true > /etc/machine-id 

# Disable grub
rm -rf /boot/grub

# Disable apparmor
systemctl mask apparmor

# Add new users to the video group
sed -i 's/#EXTRA_GROUPS=.*/EXTRA_GROUPS="video"/g' /etc/adduser.conf
sed -i 's/#ADD_EXTRA_GROUPS=.*/ADD_EXTRA_GROUPS=1/g' /etc/adduser.conf

# Override u-boot-menu config  
mkdir -p /usr/share/u-boot-menu/conf.d
cat << 'EOF' > /usr/share/u-boot-menu/conf.d/ubuntu.conf
U_BOOT_PROMPT="1"
U_BOOT_PARAMETERS="$(cat /etc/kernel/cmdline)"
U_BOOT_TIMEOUT="20"
EOF

# Default kernel command line arguments
echo -n "rootwait rw console=ttyS2,1500000 console=tty1 cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory" > /etc/kernel/cmdline

if [ "$1" == "desktop-preinstalled" ]; then
    # The cloud-init will not allow for user groups to be assigned on the first login
    apt-get -y purge cloud-init

    # Prepare required oem installer paths 
    mkdir -p /var/log/installer
    touch /var/log/installer/debug
    touch /var/log/syslog
    chown syslog:adm /var/log/syslog

    # Create the oem user account only if it doesn't already exist
    if ! id "oem" &>/dev/null; then
        /usr/sbin/useradd -d /home/oem -G adm,sudo,video -m -N -u 29999 oem
        /usr/sbin/oem-config-prepare --quiet
        touch "/var/lib/oem-config/run"
    fi

    # Create host ssh keys (normally cloud-init does this on boot)
    ssh-keygen -A

    # Enable wayland session
    sed -i 's/#WaylandEnable=false/WaylandEnable=true/g' /etc/gdm3/custom.conf

    # Adjust kernel command line arguments for desktop
    echo -n "quiet splash plymouth.ignore-serial-consoles" >> /etc/kernel/cmdline
fi

# Remove misc packages
apt-get -y purge flash-kernel fwupd 

# Update extlinux
u-boot-update

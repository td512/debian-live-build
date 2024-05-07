#!/bin/bash

if [ "$(id -u)" -ne 0 ]; then 
    echo "Please run as root"
    exit 1
fi

cd "$(dirname -- "$(readlink -f -- "$0")")" || exit 1

mkdir -p build/chroot
cd build || exit 1

# Query the system to locate livecd-rootfs auto script installation path
cp -r "$(dpkg -L livecd-rootfs | grep "auto$")" auto

while [ "$#" -gt 0 ]; do
    case "${1}" in
        -s|--server)
            export PROJECT=ubuntu-cpc
            name="server"
            shift
            ;;
        -d|--desktop)
            export SUBPROJECT=desktop-preinstalled
            export PROJECT=ubuntu
            name="desktop"
            shift
            ;;
        -b|--bookworm)
            export SUITE=bookworm
            version="22.04"
            shift
            ;;
        -t|--trixie)
            export SUITE=trixie
            version="24.04"
            shift
            ;;
        -v|--verbose)
            set -x
            shift
            ;;
        -*)
            echo "Error: unknown argument \"${1}\""
            exit 1
            ;;
        *)
            shift
            ;;
    esac
done

export ARCH=arm64
export IMAGEFORMAT=none
export IMAGE_TARGETS=none
export EXTRA_PPAS="jjriek/rockchip jjriek/rockchip-multimedia"

# Populate the configuration directory for live build
lb config \
	--architecture arm64 \
	--bootstrap-qemu-arch arm64 \
	--bootstrap-qemu-static /usr/bin/qemu-aarch64-static \
	--archive-areas "main non-free non-free-firmware contrib" \
	--parent-archive-areas "main non-free non-free-firmware contrib" \
    --mirror-bootstrap "http://deb.debian.org" \
    --parent-mirror-bootstrap "http://deb.debian.org" \
    --mirror-chroot-security "http://deb.debian.org" \
    --parent-mirror-chroot-security "http://deb.debian.org" \
    --mirror-binary-security "http://deb.debian.org" \
    --parent-mirror-binary-security "http://deb.debian.org" \
    --mirror-binary "http://deb.debian.org" \
    --parent-mirror-binary "http://deb.debian.org" \
    --keyring-packages debian-keyring \
    --linux-flavours rockchip

# Add chroot tweaks and archives
cp ../001-tweaks.chroot config/hooks/
cp ../extra-ppas.pref.chroot config/archives/
cp ../extra-ppas-ignore.pref.chroot config/archives/

sed -i 's/libgl1-amber-dri//g' config/package-lists/livecd-rootfs.list.chroot_install

# Snap packages to install
(
    echo "snapd/classic=stable"
    echo "core22/classic=stable"
    echo "lxd/classic=stable"
) > config/seeded-snaps

# Generic packages to install
(
    echo "rockchip-multimedia-config"
    echo "software-properties-common"
    echo "linux-firmware"
) > config/package-lists/my.list.chroot

if [ "${PROJECT}" == "debian" ]; then
    # Specific packages to install for debian desktop
    (
        echo "debian-desktop-rockchip"
        echo "oem-config-gtk"
        echo "ubiquity-frontend-gtk"
        echo "ubiquity-slideshow-ubuntu"
        echo "gstreamer1.0-rockchip1"
        echo "chromium-browser"
        echo "libv4l-rkmpp"
        echo "localechooser-data"
    ) >> config/package-lists/my.list.chroot
else
    # Specific packages to install for debian server
    echo "debian-server-rockchip" >> config/package-lists/my.list.chroot
fi

# Build the rootfs
lb build 

# Tar the entire rootfs
(cd chroot/ &&  tar -p -c --sort=name --xattrs ./*) | xz -3 -T0 > "debian-${version}-preinstalled-${name}-arm64.rootfs.tar.xz"

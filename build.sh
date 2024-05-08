#!/bin/bash

if [ "$(id -u)" -ne 0 ]; then 
    echo "Please run as root"
    exit 1
fi

cd "$(dirname -- "$(readlink -f -- "$0")")" || exit 1

mkdir -p debian

while [ "$#" -gt 0 ]; do
    case "${1}" in
        -s|--server)
            name="server"
            shift
            ;;
        -d|--desktop)
            name="desktop"
            shift
            ;;
        -b|--bookworm)
            export SUITE=bookworm
            shift
            ;;
        -de|--desktopenvironment)
            export DESKTOP="${2}"
            shift 2
            ;;
        -t|--trixie)
            export SUITE=trixie
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

# Leftover PPAs that need to be rebuilt
# export EXTRA_PPAS="jjriek/rockchip jjriek/rockchip-multimedia"

if [[ "$name" == "server" ]]; then
    $filename="debian-${version}-preinstalled-${name}-arm64.rootfs.tar.xz"
else
    $filename="debian-${version}-${DESKTOP}-preinstalled-${name}-arm64.rootfs.tar.xz"
fi

scripts/install-dependencies.sh
scripts/debootstrap.sh $(pwd) $SUITE
scripts/setup-chroot.sh $(pwd)
scripts/complete-debootstrap.sh $(pwd)
sudo cp scripts/os-tweaks.sh debian
sudo chroot debian ./os-tweaks.sh "preinstalled-${name}"
sudo rm debian/os-tweaks.sh
sudo cp scripts/post-debootstrap.sh debian
sudo chroot debian ./post-debootstrap.sh $SUITE
sudo rm debian/post-debootstrap.sh
if [[ "$name" == "desktop"]]; then
    sudo cp scripts/install-de.sh debian
    sudo chroot debian ./install-de.sh $DESKTOP
    sudo rm debian/install-de.sh
    sudo cp scripts/switch-target.sh debian
    sudo chroot debian ./switch-target.sh graphical
    sudo rm debian/switch-target.sh
fi
scripts/cleanup.sh $(pwd)

# Tar the entire rootfs
(cd DEBIAN/ &&  tar -p -c --sort=name --xattrs ./*) | xz -9 -T0 > $filename

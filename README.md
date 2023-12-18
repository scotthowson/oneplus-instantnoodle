# Ubuntu Touch Device Tree for the OnePlus 8 (instantnoodle)

This project is based on Halium 11.0 and provides instructions for setting up a build environment, building the device tree, and installing Ubuntu Touch on the OnePlus 8.

## Contents
- [Ubuntu Touch Device Tree for the OnePlus 8 (instantnoodle)](#ubuntu-touch-device-tree-for-the-oneplus-8-instantnoodle)
  - [Contents](#contents)
  - [Setting up Your Build Environment](#setting-up-your-build-environment)
  - [How to Build](#how-to-build)
  - [Installation Guide](#installation-guide)
    - [Unlocking Bootloader](#unlocking-bootloader)
    - [Flashing the System](#flashing-the-system)
  - [Chroot Instructions](#chroot-instructions)
    - [Using System Partition](#using-system-partition)
    - [Using Data Partition](#using-data-partition)
  - [SSH Connection](#ssh-connection)
  - [Telnet Connection](#telnet-connection)

## Setting up Your Build Environment

**Requirements**: Ubuntu (20.04 or newer)

**For amd64 architecture (commonly referred to as 64 bit)**:
Enable the i386 architecture:
```bash
sudo dpkg --add-architecture i386
sudo apt update
```

Install dependencies:
```bash
sudo apt install git gnupg flex bison gperf build-essential \
zip bzr curl libc6-dev libncurses5-dev:i386 x11proto-core-dev \
libx11-dev:i386 libreadline6-dev:i386 libgl1-mesa-glx:i386 \
libgl1-mesa-dev g++-multilib mingw-w64-i686-dev tofrodos \
python3-markdown libxml2-utils xsltproc zlib1g-dev:i386 schedtool \
liblz4-tool bc lzop imagemagick libncurses5 rsync \
python-is-python3 python2
```

Download and set up the repo tool:
```bash
curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
chmod a+rx ~/bin/repo
```

## How to Build

To build this project:
```bash
git clone https://github.com/IllSaft/oneplus-instantnoodle.git
cd oneplus-instantnoodle
sudo chmod +x build.sh
# Note: The build breaks with gcc-11
export HOSTCC=gcc-9
sudo ./build.sh -b instantnoodle
sudo ./build/prepare-fake-ota.sh instantnoodle/device_instantnoodle.tar.xz ota
sudo ./build/system-image-from-ota.sh ota/ubuntu_command out
# If built successfully, your system images will be in 'out/'
```

## Installation Guide

### Unlocking Bootloader

Ensure your device is connected:
```bash
adb devices
adb reboot fastboot
fastboot flash cust-unlock unlock_token.bin
fastboot oem unlock 
```

### Flashing the System

Prepare for flashing:
```bash
adb devices
adb reboot fastboot
fastboot delete-logical-partition product_a
fastboot delete-logical-partition system_ext_a
fastboot flash boot boot.img
fastboot flash system system.img
fastboot flash vbmeta --disable-verity --disable-verification vbmeta.img
```

## Chroot Instructions

### Using System Partition

Access the system partition:
```bash
adb reboot recovery
adb shell
mkdir /mnt/system
mount -o loop /dev/block/dm-0 /mnt/system
export PATH=/bin:/usr/bin:/sbin:/usr/sbin:/usr/local/bin
mount --bind /dev /mnt/system/dev
mount --bind /dev/pts /mnt/system/dev/pts
mount --bind /sys /mnt/system/sys
mount --bind /proc /mnt/system/proc
chroot /mnt/system /bin/bash
# [Additional chroot commands]
exit
umount /mnt/system/dev/pts
umount /mnt/system/dev
umount /mnt/system/sys
umount /mnt/system/proc
umount /mnt/system
```

### Using Data Partition

Using the chroot script:
```bash
adb reboot recovery
adb push chroot-files/chroot-log-data.sh /
adb shell
chmod +x ./chroot-log-data.sh
./chroot-log-data.sh
```

Manually mounting:
```bash
mount -o loop /data /mnt/ubuntu
export PATH=/bin:/usr/bin:/sbin:/usr/sbin:/usr/local/bin
mount --bind /dev /mnt/ubuntu/dev
mount --bind /dev/pts /mnt/ubuntu/dev/pts
mount --bind /sys /mnt/ubuntu/sys
mount --bind /proc /mnt/ubuntu/proc
chroot /mnt/ubuntu /bin/bash
exit
umount /mnt/ubuntu/dev/pts
umount /mnt/ubuntu/dev
umount /mnt/ubuntu/sys
umount /mnt/ubuntu/proc
umount /mnt/ubuntu
```

## SSH Connection
```bash
sudo ip link set down <devicename> && sudo ip link set <devicename> name OnePlus-8 && sudo ip link set up OnePlus-8
sudo ip address add 10.15.19.100/24 dev OnePlus-8
sudo ip link set OnePlus-8 up
ssh phablet@10.15.19.82
```

## Telnet Connection
```bash
telnet 192.168.2.15
```

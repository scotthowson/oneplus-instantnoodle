# Ubuntu Touch Device Tree for the OnePlus 8 (instantnoodle)

This guide provides detailed instructions for setting up a build environment, building the Ubuntu Touch device tree, and installing it on the OnePlus 8, based on Halium 11.0. It is designed for developers and advanced users who wish to run Ubuntu Touch on their OnePlus 8 devices (model: instantnoodle).

## Contents
- [Ubuntu Touch Device Tree for the OnePlus 8 (instantnoodle)](#ubuntu-touch-device-tree-for-the-oneplus-8-instantnoodle)
  - [Contents](#contents)
- [Introduction](#introduction)
  - [Prerequisites and Warnings](#prerequisites-and-warnings)
  - [Setting up Your Build Environment](#setting-up-your-build-environment)
  - [Install dependencies:](#install-dependencies)
    - [How to Build](#how-to-build)
  - [Installation Guide](#installation-guide)
    - [Unlocking Bootloader](#unlocking-bootloader)
  - [How to Flash Recovery](#how-to-flash-recovery)
    - [Flashing Recovery](#flashing-recovery)
  - [How to Flash](#how-to-flash)
    - [Using System Partition](#using-system-partition)
      - [Chroot Instructions](#chroot-instructions)
        - [Using the System Partition chroot script:](#using-the-system-partition-chroot-script)
        - [Manually mounting System Partition:](#manually-mounting-system-partition)
    - [Using Userdata Partition DD method](#using-userdata-partition-dd-method)
      - [Chroot Instructions](#chroot-instructions-1)
        - [Using the Userdata Partition DD chroot script:](#using-the-userdata-partition-dd-chroot-script)
        - [Manually mounting Data Partition DD method:](#manually-mounting-data-partition-dd-method)
    - [Using Userdata Partition ADB push method](#using-userdata-partition-adb-push-method)
      - [Chroot Instructions](#chroot-instructions-2)
        - [Using the Userdata Partition chroot script:](#using-the-userdata-partition-chroot-script)
        - [Manually mounting Data Partition ADB push method:](#manually-mounting-data-partition-adb-push-method)
  - [Getting Started with SSH \& Telnet!](#getting-started-with-ssh--telnet)
    - [SSH Connection](#ssh-connection)
    - [Telnet Connection](#telnet-connection)
  - [Troubleshooting](#troubleshooting)
  - [Contributing](#contributing)
  - [References and Credits](#references-and-credits)
  - [Special Thanks](#special-thanks)

# Introduction
This guide is specifically tailored for the OnePlus 8 device and covers the entire process from setting up the necessary environment to the final installation of Ubuntu Touch. Users are expected to have basic knowledge of Linux command line and Android development tools.

## Prerequisites and Warnings
> [!NOTE] 
> OnePlus 8 (instantnoodle).

> [!IMPORTANT]s
> [!CAUTION]
> This guide involves procedures like unlocking the bootloader, flashing firmware, and modifying system components. These actions can potentially lead to negative outcomes, such as voiding your warranty, bricking your device, or compromising its security. Proceed with full understanding of the risks and ensure you follow the instructions carefully.

## Setting up Your Build Environment

**Requirements**: Ubuntu (20.04 or newer)

**For amd64 architecture (commonly referred to as 64 bit)**:

Enable the i386 architecture:
```bash
sudo dpkg --add-architecture i386
sudo apt update
```

## Install dependencies:
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

### How to Build

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
## How to Flash Recovery
### Flashing Recovery
Prepare your device for flashing:
```bash
sudo chmod +x fetch-instantnoodle-recovery-files.sh
./fetch-instantnoodle-recovery-files.sh
# Accept both prompts.
adb devices
adb reboot fastboot
# If you have stock rom you may need to press advanced & enter fastboot again.
# Orange Fox Recovery
fastboot flash recovery instantnoodle-extras/recovery/OrangeFox_R11.1-InstantNoodle-Recovery.img
# TeamWin Recovery (TWRP)
fastboot flash recovery instantnoodle-extras/recovery/TWRP-InstantNoodle-Recovery.img
# LineageOS 18.1 Recovery
fastboot flash recovery instantnoodle-extras/recovery/LineageOS-18.1-Recovery.img
# Once flashed run:
fastboot reboot recovery
```



## How to Flash
### Using System Partition
```bash
adb devices
adb reboot fastboot
fastboot delete-logical-partition product_a
fastboot flash boot boot.img
fastboot flash system system.img
fastboot flash vbmeta --disable-verity --disable-verification vbmeta.img
```
#### Chroot Instructions
##### Using the System Partition chroot script:
```bash
adb reboot recovery
adb push chroot-files/chroot-log-system.sh /
adb shell
chmod +x ./chroot-log-system.sh
./chroot-log-system.sh
```
##### Manually mounting System Partition:
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
umount -l /mnt/system/dev/pts
umount -l /mnt/system/dev
umount -l /mnt/system/sys
umount -l /mnt/system/proc
umount -l /mnt/system
```


### Using Userdata Partition DD method
```bash
adb devices
adb reboot fastboot
fastboot flash boot boot.img
fastboot reboot recovery
adb push out/ubuntu.img /sdcard/
dd if=/sdcard/ubuntu.img of=/dev/block/by-name/userdata
fastboot flash vbmeta --disable-verity --disable-verification vbmeta.img
```
#### Chroot Instructions
##### Using the Userdata Partition DD chroot script:
```bash
adb reboot recovery
adb push chroot-files/chroot-log-data-dd.sh /
adb shell
mkdir -p /tmp/data; mount /dev/block/by-name/userdata /tmp/data
chmod +x ./chroot-log-data-dd.sh
./chroot-log-data-dd.sh
```
##### Manually mounting Data Partition DD method:
```bash
mkdir /data
mount -o loop /dev/block/by-name/userdata /data
export PATH=/bin:/usr/bin:/sbin:/usr/sbin:/usr/local/bin
mount --bind /dev /data/dev
mount --bind /dev/pts /data/dev/pts
mount --bind /sys /data/sys
mount --bind /proc /data/proc
chroot /data /bin/bash
exit
# Once done, unmount all partitions.
umount -l /data/dev/pts
umount -l /data/dev
umount -l /data/sys
umount -l /data/proc
umount -l /data
```

### Using Userdata Partition ADB push method
```bash
adb devices
adb reboot fastboot
fastboot flash boot boot.img
fastboot reboot recovery
# Veryify device is in 'Recovery' mode.
adb devices
adb push out/ubuntu.img /data/
fastboot flash boot boot.img
fastboot flash system system.img
fastboot flash vbmeta --disable-verity --disable-verification vbmeta.img
```
#### Chroot Instructions
##### Using the Userdata Partition chroot script:
```bash
adb reboot recovery
adb push chroot-files/chroot-log-data.sh /
adb shell
chmod +x ./chroot-log-data.sh
./chroot-log-data.sh
```
##### Manually mounting Data Partition ADB push method:
```bash
mkdir /mnt/ubuntu
mount -o loop /data/ubuntu.img /mnt/ubuntu
export PATH=/bin:/usr/bin:/sbin:/usr/sbin:/usr/local/bin
mount --bind /dev /mnt/ubuntu/dev
mount --bind /dev/pts /mnt/ubuntu/dev/pts
mount --bind /sys /mnt/ubuntu/sys
mount --bind /proc /mnt/ubuntu/proc
chroot /mnt/ubuntu /bin/bash
exit
# Once done, unmount all partitions.
umount -l /mnt/ubuntu/dev/pts
umount -l /mnt/ubuntu/dev
umount -l /mnt/ubuntu/sys
umount -l /mnt/ubuntu/proc
umount -l /mnt/ubuntu
```

## Getting Started with SSH & Telnet!
First we will be setting the device to be called OnePlus-8
```bash
ip route show
# The device name will most likely resemble 'enp0s29u1u1'.
sudo sh -c 'ip link set down dev <devicename> && ip link set dev <devicename> name OnePlus-8 && ip link set up dev OnePlus-8'
# Once done we will run this command to verify that we see '192.168.2.0/24 dev OnePlus-8 proto kernel ...'
ip route show
```

### SSH Connection
```bash
sudo sh -c 'ip link set dev OnePlus-8 up && ip address add 10.15.19.82 dev OnePlus-8 && ip route add 10.15.19.100 dev OnePlus-8'

sudo ip address add 10.15.19.100/24 dev OnePlus-8
sudo ip link set OnePlus-8 up
ssh phablet@10.15.19.82
```

### Telnet Connection
```bash
sudo sh -c 'ip link set dev OnePlus-8 up && ip address add 192.168.2.20 dev OnePlus-8 && ip route add 192.168.2.15 dev OnePlus-8'

ip link set OnePlus-8 address 02:11:22:33:44:55
ip address add 10.15.19.100/24 dev OnePlus-8
ip link set OnePlus-8 up

ip r

telnet 192.168.2.15
```

## Troubleshooting
Common issues and their solutions will be listed [here](https://docs.ubports.com/en/latest/porting/configure_test_fix/index.html). If you encounter any problems, refer to this section for guidance.

```bash
# you can try to chroot the into rootfs and perform:
systemctl mask usb-moded
systemctl enable usb-tethering
systemctl enable ssh
```


## Contributing
[Contributions](https://docs.ubports.com/en/latest/contribute/index.html) to this guide are welcome. If you have suggestions or corrections, please submit a pull request or open an issue on the GitHub repository.

## References and Credits
Acknowledgments to individuals or sources that have contributed to this guide.
[OnePlus Kebab repository](https://gitlab.com/DaniAsh551/oneplus-kebab) - [DaniAsh551](https://gitlab.com/DaniAsh551)

## Special Thanks
A heartfelt thank you to [DaniAsh551](https://gitlab.com/DaniAsh551) and their [OnePlus Kebab repository](https://gitlab.com/DaniAsh551/oneplus-kebab) for their invaluable assistance and patience throughout the development of this project. Their contributions and guidance have been instrumental in its success.

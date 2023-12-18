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
      - [Flashing Recovery](#flashing-recovery)
      - [Flashing the System](#flashing-the-system)
    - [Chroot Instructions](#chroot-instructions)
      - [Using System Partition](#using-system-partition)
        - [Using the chroot script:](#using-the-chroot-script)
        - [Manually mounting System Partition:](#manually-mounting-system-partition)
        - [Using Data Partition](#using-data-partition)
        - [Using the chroot script:](#using-the-chroot-script-1)
        - [Manually mounting Data Partition:](#manually-mounting-data-partition)
    - [SSH Connection](#ssh-connection)
    - [Telnet Connection](#telnet-connection)
  - [Troubleshooting](#troubleshooting)
  - [Contributing](#contributing)
  - [References and Credits](#references-and-credits)
  - [Special Thanks](#special-thanks)

## Introduction
This guide is specifically tailored for the OnePlus 8 device and covers the entire process from setting up the necessary environment to the final installation of Ubuntu Touch. Users are expected to have basic knowledge of Linux command line and Android development tools.

### Prerequisites and Warnings
> [!NOTE] 
> OnePlus 8 (instantnoodle).

> [!IMPORTANT]
> Unlocked bootloader, root access.

> [!WARNING]
> Following these instructions can void your warranty and may potentially brick your device. Proceed with caution and understand the risks involved.

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

### Install dependencies:
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
#### Flashing Recovery
Prepare your device for flashing:
```bash
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



#### Flashing the System

Prepare for flashing:
```bash
adb devices
adb reboot fastboot
fastboot delete-logical-partition product_a
fastboot flash boot boot.img
fastboot flash system system.img
fastboot flash vbmeta --disable-verity --disable-verification vbmeta.img
```

### Chroot Instructions
#### Using System Partition
##### Using the chroot script:
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
umount /mnt/system/dev/pts
umount /mnt/system/dev
umount /mnt/system/sys
umount /mnt/system/proc
umount /mnt/system
```

##### Using Data Partition
##### Using the chroot script:
```bash
adb reboot recovery
adb push chroot-files/chroot-log-data.sh /
adb shell
chmod +x ./chroot-log-data.sh
./chroot-log-data.sh
```

##### Manually mounting Data Partition:
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
umount /mnt/ubuntu/dev/pts
umount /mnt/ubuntu/dev
umount /mnt/ubuntu/sys
umount /mnt/ubuntu/proc
umount /mnt/ubuntu
```

### SSH Connection
```bash
ip link show
sudo ip link set down <devicename> && sudo ip link set <devicename> name OnePlus-8 && sudo ip link set up OnePlus-8
sudo ip address add 10.15.19.100/24 dev OnePlus-8
sudo ip link set OnePlus-8 up
ssh phablet@10.15.19.82
```

### Telnet Connection
```bash
telnet 192.168.2.15
```

## Troubleshooting
Common issues and their solutions will be listed [here](https://docs.ubports.com/en/latest/porting/configure_test_fix/index.html). If you encounter any problems, refer to this section for guidance.

## Contributing
[Contributions](https://docs.ubports.com/en/latest/contribute/index.html) to this guide are welcome. If you have suggestions or corrections, please submit a pull request or open an issue on the GitHub repository.

## References and Credits
Acknowledgments to individuals or sources that have contributed to this guide.
[OnePlus Kebab repository](https://gitlab.com/DaniAsh551/oneplus-kebab) - [DaniAsh551](https://gitlab.com/DaniAsh551)

## Special Thanks
A heartfelt thank you to [DaniAsh551](https://gitlab.com/DaniAsh551) and their [OnePlus Kebab repository](https://gitlab.com/DaniAsh551/oneplus-kebab) for their invaluable assistance and patience throughout the development of this project. Their contributions and guidance have been instrumental in its success.

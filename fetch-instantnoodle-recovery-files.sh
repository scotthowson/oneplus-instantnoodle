#!/bin/bash

download_files() {
    if [ ! -f OrangeFox_R11.1-InstantNoodle-Recovery.img ] || [ ! -f TWRP-InstantNoodle-Recovery.img ] || [ ! -f LineageOS-18.1-Recovery.img ]; then
        wget -O OrangeFox_R11.1-InstantNoodle-Recovery.img https://github.com/Wishmasterflo/android_device_oneplus_kebab/releases/download/V15/OrangeFox-R11.1-Unofficial-OnePlus8T_9R-V15.img
        wget -O LineageOS-18.1-Recovery.img https://github.com/IllSaft/los18.1-recovery/releases/download/0.1/LineageOS-18.1-Recovery.img
        curl --referer 'https://dl.twrp.me/instantnoodle/twrp-3.7.0_11-0-instantnoodle.img' -k -o TWRP-InstantNoodle-Recovery.img https://dl.twrp.me/instantnoodle/twrp-3.7.0_11-0-instantnoodle.img
        echo -e "\e[92mRecovery files downloaded successfully.\e[0m"
        echo -e "\e[96mRecovery files saved to: $(pwd)\e[0m"
    else
        read -p "Recovery files already exist. Would you like to redownload? (y/n): " choice
        case "$choice" in
            [Yy]*)
                rm -f OrangeFox_R11.1-InstantNoodle-Recovery.img TWRP-InstantNoodle-Recovery.img
                download_files
                ;;
            [Nn]*)
                echo -e "\e[91mRecovery files not downloaded.\e[0m"
                ;;
            *)
                echo -e "\e[91mInvalid choice. Please enter 'y' for yes or 'n' for no.\e[0m"
                ;;
        esac
    fi
}

clone_repository() {
    if [ ! -d "instantnoodle-extras/halium-boot" ]; then
        mkdir -p instantnoodle-extras/halium-boot || { echo -e "\e[91mFailed to create directory\e[0m"; exit 1; }
        git clone https://github.com/Halium/halium-boot.git instantnoodle-extras/halium-boot || { echo -e "\e[91mFailed to clone repository\e[0m"; exit 1; }
        wget -O instantnoodle-extras/halium-boot/instantnoodle_user_defconfig https://raw.githubusercontent.com/IllSaft/halium_kernel_oneplus_sm8250/halium-11.0/arch/arm64/configs/vendor/instantnoodle_user_defconfig
        wget -O instantnoodle-extras/chroot/chroot-log-data.sh https://raw.githubusercontent.com/IllSaft/instantnoodle-chroot/main/chroot-log-data.sh
        wget -O instantnoodle-extras/chroot/chroot-log-system.sh https://raw.githubusercontent.com/IllSaft/instantnoodle-chroot/main/chroot-log-system.sh
        wget -O instantnoodle-extras/chroot/README.md https://raw.githubusercontent.com/IllSaft/instantnoodle-chroot/main/README.md
        wget -O instantnoodle-extras/chroot/Instantnoodle-Info.log https://raw.githubusercontent.com/IllSaft/instantnoodle-chroot/main/Instantnoodle-Info
        wget -O instantnoodle-extras/recovery/Instantnoodle-Recovery.log https://raw.githubusercontent.com/IllSaft/instantnoodle-chroot/main/Instantnoodle-Recovery.log
        rm instantnoodle-extras/halium-boot/Android.mk instantnoodle-extras/halium-boot/get-initrd.sh instantnoodle-extras/halium-boot/LICENSE instantnoodle-extras/halium-boot/README.md
        echo -e "\e[92mRepository cloned successfully.\e[0m"
        echo -e "\e[96mRepository cloned to: $(pwd)/instantnoodle-extras/halium-boot\e[0m"
    else
        read -p "Repository already exists. Would you like to re-clone? (y/n): " choice
        case "$choice" in
            [Yy]*)
                rm -rf instantnoodle-extras/halium-boot
                clone_repository
                ;;
            [Nn]*)
                echo -e "\e[91mRepository not cloned.\e[0m"
                ;;
            *)
                echo -e "\e[91mInvalid choice. Please enter 'y' for yes or 'n' for no.\e[0m"
                ;;
        esac
    fi
}

main() {
    mkdir -p instantnoodle-extras/halium-boot instantnoodle-extras/chroot instantnoodle-extras/recovery || { echo -e "\e[91mFailed to create directories\e[0m"; exit 1; }
    cd instantnoodle-extras/recovery || { echo -e "\e[91mFailed to change directory\e[0m"; exit 1; }
    download_files || { echo -e "\e[91mFailed to download files\e[0m"; exit 1; }
    cd "$OLDPWD" || { echo -e "\e[91mFailed to change back to the original directory\e[0m"; exit 1; }
    clone_repository || { echo -e "\e[91mFailed to clone repository\e[0m"; exit 1; }
}
main
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
    if [ ! -d "Instantnoodle-Extras/Halium-Boot" ]; then
        mkdir -p Instantnoodle-Extras/Halium-Boot || { echo -e "\e[91mFailed to create directory\e[0m"; exit 1; }
        git clone https://github.com/Halium/halium-boot.git Instantnoodle-Extras/Halium-Boot || { echo -e "\e[91mFailed to clone repository\e[0m"; exit 1; }
        wget -O Instantnoodle-Extras/Halium-Boot/instantnoodle_user_defconfig https://raw.githubusercontent.com/IllSaft/halium_kernel_oneplus_sm8250/halium-11.0/arch/arm64/configs/vendor/instantnoodle_user_defconfig
        wget -O Instantnoodle-Extras/Chroot/chroot.sh https://raw.githubusercontent.com/IllSaft/instantnoodle-chroot/main/chroot.sh
        wget -O Instantnoodle-Extras/Chroot/README.md https://raw.githubusercontent.com/IllSaft/instantnoodle-chroot/main/README.md
        wget -O Instantnoodle-Extras/Chroot/Instantnoodle-Info.log https://raw.githubusercontent.com/IllSaft/instantnoodle-chroot/main/Instantnoodle-Info
        wget -O Instantnoodle-Extras/Recovery/Instantnoodle-Recovery.log https://raw.githubusercontent.com/IllSaft/instantnoodle-chroot/main/Instantnoodle-Recovery.log
        rm Instantnoodle-Extras/Halium-Boot/Android.mk Instantnoodle-Extras/Halium-Boot/get-initrd.sh Instantnoodle-Extras/Halium-Boot/LICENSE Instantnoodle-Extras/Halium-Boot/README.md
        echo -e "\e[92mRepository cloned successfully.\e[0m"
        echo -e "\e[96mRepository cloned to: $(pwd)/Instantnoodle-Extras/Halium-Boot\e[0m"
    else
        read -p "Repository already exists. Would you like to re-clone? (y/n): " choice
        case "$choice" in
            [Yy]*)
                rm -rf Instantnoodle-Extras/Halium-Boot
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
    mkdir -p Instantnoodle-Extras/Halium-Boot Instantnoodle-Extras/Chroot Instantnoodle-Extras/Recovery || { echo -e "\e[91mFailed to create directories\e[0m"; exit 1; }
    cd Instantnoodle-Extras/Recovery || { echo -e "\e[91mFailed to change directory\e[0m"; exit 1; }
    download_files || { echo -e "\e[91mFailed to download files\e[0m"; exit 1; }
    cd "$OLDPWD" || { echo -e "\e[91mFailed to change back to the original directory\e[0m"; exit 1; }
    clone_repository || { echo -e "\e[91mFailed to clone repository\e[0m"; exit 1; }
}
main
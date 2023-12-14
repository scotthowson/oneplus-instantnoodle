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

main() {
    mkdir -p Instantnoodle-Extras/Recovery || { echo -e "\e[91mFailed to create directory\e[0m"; exit 1; }
    current_dir=$(pwd)
    cd Instantnoodle-Extras/Recovery || { echo -e "\e[91mFailed to change directory\e[0m"; exit 1; }
    download_files || { echo -e "\e[91mFailed to download files\e[0m"; exit 1; }
    cd "$current_dir" || { echo -e "\e[91mFailed to change back to original directory\e[0m"; exit 1; }
}
main
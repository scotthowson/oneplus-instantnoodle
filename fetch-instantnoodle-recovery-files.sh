#!/bin/bash

# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
MAGENTA='\033[1;35m'
NC='\033[0m' # No Color

# Function to display a colored message
echo_color() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Decorative divider
divider() {
    echo_color $CYAN "------------------------------------------------"
}

download_file() {
    local url=$1
    local file=$2
    local option=$3
    local option_url=$4

    echo_color $MAGENTA "🚀 Downloading: $file"
    if [[ $option == "wget" ]]; then
        wget -O "$file" "$url" &> /dev/null
    elif [[ $option == "curl" ]]; then
        curl --referer "$option_url" -k -o "$file" "$url" &> /dev/null
    fi
    echo_color $GREEN "✅ $file downloaded successfully."
}

download_files() {
    local files=(
        "OrangeFox_R11.1-InstantNoodle-Recovery.img|wget|https://github.com/Wishmasterflo/android_device_oneplus_kebab/releases/download/V15/OrangeFox-R11.1-Unofficial-OnePlus8T_9R-V15.img"
        "TWRP-InstantNoodle-Recovery.img|curl|https://dl.twrp.me/instantnoodle/twrp-3.7.0_11-0-instantnoodle.img|https://dl.twrp.me/instantnoodle/"
        "LineageOS-18.1-Recovery.img|wget|https://github.com/IllSaft/los18.1-recovery/releases/download/0.1/LineageOS-18.1-Recovery.img"
    )

    divider
    for entry in "${files[@]}"; do
        IFS='|' read -r file option url option_url <<< "$entry"
        download_file "$url" "$file" "$option" "$option_url"
    done
    divider

    echo_color $GREEN "🎉 All recovery files downloaded successfully."
}

prompt_user() {
    local prompt_message=$1
    echo_color $YELLOW "$prompt_message"
    read -p "" choice
    case "$choice" in
        [Yy]* )
            return 0
            ;;
        [Nn]* )
            return 1
            ;;
        * )
            echo_color $RED "❌ Invalid choice. Please enter 'y' for yes or 'n' for no."
            return 1
            ;;
    esac
}

check_and_download_chroot_scripts() {
    local chroot_path="instantnoodle-extras/chroot"

    if [ -f "$chroot_path/chroot-log-data.sh" ] || [ -f "$chroot_path/chroot-log-system.sh" ]; then
        if prompt_user "📁 Chroot scripts already exist. Would you like to redownload them? (y/n): "; then
            download_chroot_scripts "$chroot_path"
        else
            echo_color $BLUE "🔄 Chroot scripts not redownloaded."
        fi
    else
        download_chroot_scripts "$chroot_path"
    fi
}

download_chroot_scripts() {
    local chroot_path=$1

    divider
    download_file "https://raw.githubusercontent.com/IllSaft/instantnoodle-chroot/main/chroot-log-data.sh" "$chroot_path/chroot-log-data.sh" "wget"
    download_file "https://raw.githubusercontent.com/IllSaft/instantnoodle-chroot/main/chroot-log-system.sh" "$chroot_path/chroot-log-system.sh" "wget"
    download_file "https://raw.githubusercontent.com/IllSaft/instantnoodle-chroot/main/README.md" "$chroot_path/README.md" "wget"
    download_file "https://raw.githubusercontent.com/IllSaft/instantnoodle-chroot/main/Instantnoodle-Info.log" "$chroot_path/Instantnoodle-Info.log" "wget"
    download_file "https://raw.githubusercontent.com/IllSaft/instantnoodle-chroot/main/Instantnoodle-Recovery.log" "instantnoodle-extras/recovery/Instantnoodle-Recovery.log" "wget"
    divider

    echo_color $GREEN "🎉 Chroot scripts downloaded successfully."
}

clone_repository() {
    local repo_path="instantnoodle-extras/halium-boot"
    if [ -d "$repo_path" ]; then
        if prompt_user "🔍 Repository $repo_path already exists. Would you like to re-clone it? (y/n): "; then
            rm -rf "$repo_path"
        else
            echo_color $BLUE "🔄 Repository not re-cloned."
            return
        fi
    fi

    mkdir -p "$repo_path" || { echo_color $RED "❌ Failed to create directory $repo_path"; exit 1; }
    echo_color $MAGENTA "🚀 Cloning repository..."
    git clone https://github.com/Halium/halium-boot.git "$repo_path" &> /dev/null || { echo_color $RED "❌ Failed to clone repository"; exit 1; }
    download_file "https://raw.githubusercontent.com/IllSaft/halium_kernel_oneplus_sm8250/halium-11.0/arch/arm64/configs/vendor/instantnoodle_user_defconfig" "$repo_path/instantnoodle_user_defconfig" "wget"
    rm "$repo_path/Android.mk" "$repo_path/get-initrd.sh" "$repo_path/LICENSE" "$repo_path/README.md"
    echo_color $GREEN "✅ Repository cloned successfully."
}

main() {
    echo_color $CYAN "🐧 Starting the OnePlus 8 Instantnoodle Extras Download Tool Setup Script..."
    mkdir -p instantnoodle-extras/halium-boot instantnoodle-extras/chroot instantnoodle-extras/recovery || { echo_color $RED "❌ Failed to create directories"; exit 1; }
    cd instantnoodle-extras/recovery || { echo_color $RED "❌ Failed to change directory"; exit 1; }
    if [ -f OrangeFox_R11.1-InstantNoodle-Recovery.img ] && [ -f TWRP-InstantNoodle-Recovery.img ] && [ -f LineageOS-18.1-Recovery.img ]; then
        if prompt_user "📂 Recovery files already exist. Would you like to redownload them? (y/n): "; then
            download_files
        else
            echo_color $BLUE "🔄 Recovery files not redownloaded."
        fi
    else
        download_files
    fi
    cd "$OLDPWD" || { echo_color $RED "❌ Failed to change back to the original directory"; exit 1; }

    clone_repository
    check_and_download_chroot_scripts
    echo_color $GREEN "OnePlus 8 Instantnoodle Extras Download Tool Finished."
}
main

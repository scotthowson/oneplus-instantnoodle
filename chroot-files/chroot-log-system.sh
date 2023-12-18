#!/bin/bash

# Define a log file
LOG_FILE="/mnt/system/mount_script.log"

# Function to add log entries
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S'): $@" | tee -a $LOG_FILE
}

# Start the script
log "Entering Chroot Environment."

# Mount the filesystem
mkdir -p /mnt/system && log "Created /mnt/system directory." || log "Failed to create /mnt/system directory."

if mount -o loop /dev/block/dm-0 /mnt/system; then
    log "Mounted /dev/block/dm-0 to /mnt/system."
else
    log "Failed to mount /dev/block/dm-0 to /mnt/system."
    exit 1
fi

# Create a custom /etc/group file in the chroot environment
echo "Creating custom /etc/group file in the chroot environment."
echo "group1:x:1007:" > /mnt/system/etc/group
echo "group2:x:1011:" >> /mnt/system/etc/group
echo "group3:x:1028:" >> /mnt/system/etc/group
echo "group4:x:1078:" >> /mnt/system/etc/group
echo "group5:x:1079:" >> /mnt/system/etc/group
echo "group6:x:3001:" >> /mnt/system/etc/group
echo "group7:x:3006:" >> /mnt/system/etc/group
echo "group8:x:3009:" >> /mnt/system/etc/group
echo "group9:x:3011:" >> /mnt/system/etc/group
echo "group10:x:0:" >> /mnt/system/etc/group
echo "group11:x:1004:" >> /mnt/system/etc/group
echo "group12:x:1015:" >> /mnt/system/etc/group
echo "group13:x:3002:" >> /mnt/system/etc/group
echo "group13:x:3003:" >> /mnt/system/etc/group
log "Custom /etc/group file created."

# Set the PATH environment variable
export PATH=/bin:/usr/bin:/sbin:/usr/sbin:/usr/local/bin
log "Set PATH environment variable."

# Bind mount important directories
if mount --bind /dev /mnt/system/dev && 
   mount --bind /dev/pts /mnt/system/dev/pts && 
   mount --bind /sys /mnt/system/sys && 
   mount --bind /proc /mnt/system/proc; then
    log "Bind mounted important directories."
else
    log "Failed to bind mount important directories."
    exit 1
fi

# Enter the chroot environment
log "Entered chroot environment."
chroot /mnt/system /bin/bash

# The following will execute after you exit the chroot environment

# Check disk usage and report if it's over a certain threshold
df -h | grep '/mnt/system' | awk '{print $5}' | while read -r usage; do
    if [ "${usage%*%}" -gt 75 ]; then
        log "Warning: Disk usage is over 75% on /mnt/system"
    fi
done

# Log storage use percentage
storage_usage=$(df -h | grep '/mnt/system' | awk '{print $5}')
log "Storage usage on /mnt/system: $storage_usage"

# Log users in home directory
if [ -d "/mnt/system/home" ]; then
    log "Users in /mnt/system/home:"
    for user_home in /mnt/system/home/*; do
        if [ -d "$user_home" ]; then
            user=$(basename "$user_home")
            log " - $user"
        fi
    done
else
    log "Home directory /mnt/system/home not found."
fi

# Create custom logs
echo "$(date): Exited chroot environment" >> $LOG_FILE

# Check for specific files and take action
if [ -f /mnt/system/bin/sh ]; then
    log "Found bin/sh."
else
    log "bin/sh not found. ERROR!"
fi

# Run custom scripts or commands
# log "Running custom scripts or commands."
# /mnt/system/custom_script.sh
# Remove the custom /etc/group file
rm -f /mnt/system/etc/group && log "Custom /etc/group file removed."

# Cleanup: unmount bound directories
if umount /mnt/system/dev/pts && 
   umount /mnt/system/dev && 
   umount /mnt/system/sys && 
   umount /mnt/system/proc && 
   umount /mnt/system; then
    log "Unmounted all directories."
else
    log "Failed to unmount some directories."
fi

log "Chroot Environment Exited Successfully."

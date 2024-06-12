#!/bin/bash
set -xe

ADAPTATION_TOOLS_BRANCH=main

# Set the number of CPU cores allowed for the build
CPU_CORES_ALLOWED=16  # Change this to the desired number of CPU cores

# Clone the adaptation tools if the build directory doesn't exist
if [ ! -d build ]; then
  git clone -b $ADAPTATION_TOOLS_BRANCH https://gitlab.com/ubports/porting/community-ports/halium-generic-adaptation-build-tools.git build
fi

# Print the file before modification
echo "Before modification:"
cat ./build/build-kernel.sh

# Modify the build-kernel.sh script to replace the make command with -j$CPU_CORES_ALLOWED
sed -i 's/make O="$OUT" $MAKEOPTS -j$(nproc --all)/make O="$OUT" $MAKEOPTS -j$CPU_CORES_ALLOWED/' ./build/build-kernel.sh

# Print the file after modification
echo "After modification:"
cat ./build/build-kernel.sh

# Ensure build-kernel.sh is executable
chmod +x ./build/build-kernel.sh

# Execute the build script with provided arguments
./build/build.sh "$@"

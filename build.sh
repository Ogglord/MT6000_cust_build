#!/bin/bash

# Exit immediately on error
set -e

# Function to handle errors
error_exit() {
    echo "Error occurred on line $1. Exiting script."
    echo "Check build.log for errors during build."
    exit 1
}

# Trap errors and call error_exit with the line number
trap 'error_exit $LINENO' ERR

echo "Starting the build process..."

# Run make download
echo "Running 'make download'..."
make download

# Run make with specific flags and log output
echo "Running 'make -j14 V=s'..."
make -j14 V=s 2>&1 | tee build.log | grep -i -E "^make.*(error|[12345]...Entering dir)"

# Copy configuration files to the git directory
echo "Copying .config and diffconfig to 'bin/config'..."
cp .config ./bin/config/
./scripts/diffconfig.sh > diffconfig
cp diffconfig ./bin/config/

# Git operations with user confirmation
cd bin || exit 1

echo "Preparing to commit and push changes to the Git repository."
git add .

read -p "Do you want to commit and push changes? (y/n): " confirm
if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
    git commit -m "Automatic commit"
    git push
    echo "Changes committed and pushed successfully."
else
    echo "Skipping commit and push."
fi

echo "Build process completed! Check build.log for full output."

#!/bin/env bash
GO_VERSION=1.22.5
echo "Setup script for Ubuntu"

# Exit immediately on error
set -e

# Function to handle errors
error_exit() {
    echo "Error occurred on line $1. Exiting script."
    exit 1
}

# Trap errors and call error_exit with the line number
trap 'error_exit $LINENO' ERR

# Check if script is run as sudo
if [[ "$EUID" -ne 0 ]]; then
    echo "This script must be run as sudo. Exiting."
    exit 1
fi

# Determine the invoking username
if [[ -z "$SUDO_USER" ]]; then
    read -p "Unable to determine invoking username. Please enter it: " INVOKING_USER
else
    INVOKING_USER="$SUDO_USER"
fi

echo "Running script as user: $INVOKING_USER"

# Main script logic
echo "Starting operations..."


echo "Running apt update and apt install..."
apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends \
    bison \
    build-essential \
    ca-certificates \
    clang \
    cmake \
    curl \
    file \
    flex \
    g++ \
    gawk \
    gettext \
    git \
    gnupg \
    less \
    libelf-dev \
    libfdt-dev \
    libncurses5-dev \
    libssl-dev \
    lsb-release \
    nano \
    ncdu \
    openssh-client \
    python3-distutils \
    python3-setuptools \
    quilt \
    rsync \
    software-properties-common \
    squashfs-tools \
    sudo \
    swig \
    tree \
    tar \
    tzdata \
    unzip \
    vim \
    wget \
    zip \
    zlib1g-dev \
    zstd \
    libperl-dev

wget https://go.dev/dl/go${GO_VERSION}.linux-arm64.tar.gz \
    && tar -C /usr/local -xzf go${GO_VERSION}.linux-arm64.tar.gz \
    && rm -f go${GO_VERSION}.linux-arm64.tar.gz

echo "Adding /usr/local/go/bin to PATH using .bashrc..."
echo "PATH=$PATH:/usr/local/go/bin" >> /home/${INVOKING_USER}/.bashrc

echo "Installing llvm and adding LLVM_HOST_PATH to env using .bashrc..."
bash -c "$(wget -O - https://apt.llvm.org/llvm.sh)"
llvm_host_path="/usr/lib/$(ls /usr/lib/ | grep llvm | sort -r | head -1 | cut -d' ' -f11)" \
&& echo "export LLVM_HOST_PATH=$llvm_host_path" >> /home/${INVOKING_USER}/.bashrc


echo "Making sure this $INVOKING_USER can run passwordless sudo"
echo "${INVOKING_USER} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${INVOKING_USER}
    
echo "Done! Log out and back in to reload environment, or source /home/${INVOKING_USER}/.bashrc"

#! /bin/bash

read -p "Do you want create a petalinux build directory? (y/n): " user_input
if [ "$(echo $user_input | tr '[:upper:]' '[:lower:]')" = "y" ] || [ "$(echo $user_input | tr '[:upper:]' '[:lower:]')" = "yes" ]; then
    mkdir -p petalinux/build-assets \
        petalinux/build-outputs/cache/downloads \
        petalinux/build-outputs/cache/sstate-cache \
        petalinux/build-outputs/projects
    cd petalinux
else
    read -p "Where is existing petalinux build directory? [./petalinux]: " user_input
    user_input=${user_input:-./petalinux}
    if [ -d "$user_input/build-assets" ]; then
        echo "Directory $user_input will be used to store assets and output"
    else
        echo "$user_input was not found. Cannot continue"
        exit
    fi
    cd $user_input
fi

INSTALLER_BIN="petalinux-v2024.1-05202009-installer.run"
if [ ! -f "./build-assets/$INSTALLER_BIN" ]; then
    read -p "$INSTALLER_BIN was not found in ./build-assets. Copy it and press enter to continue."
    if [ ! -f "./build-assets/$INSTALLER_BIN" ]; then
        echo "The file ./build-assets/$INSTALLER_BIN cannot be found. Exiting."
        exit
    fi
fi

if id -nG "$USER" | grep -qw "docker"; then
    echo "User $USER belongs to group docker. Assuming docker is installed"
else
    sudo apt-get update
    sudo apt-get install -y ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    # Add the repository to Apt sources:
    echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" |
        sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    sudo usermod -aG docker $USER
    newgrp docker
fi

ALIAS_STRING_1="alias build-env='cd \${PETALINUX_BUILD_DIR}; docker build --progress plain -t petalinux-build-env -f container/Dockerfile .'"
ALIAS_STRING_2="alias start-build-env='docker run -v \${PETALINUX_BUILD_DIR}/build-outputs/projects:/home/petalinux/projects \\
        -v \${PETALINUX_BUILD_DIR}/build-outputs/cache/sstate-cache:/home/petalinux/cache/sstate-cache \\
        -v \${PETALINUX_BUILD_DIR}/build-outputs/cache/downloads:/home/petalinux/cache/downloads \\
        -it --rm petalinux-build-env bash'"
BASHRC="$HOME/.bashrc"

# Check if the alias already exists in .bashrc
if grep -Fxq "$ALIAS_STRING_1" "$BASHRC"; then
    echo "The alias is already in .bashrc"
else
    echo "Adding alias to .bashrc"
    echo "\n" >>"$BASHRC"
    echo "$ALIAS_STRING_1" >>"$BASHRC"
    echo "$ALIAS_STRING_2" >>"$BASHRC"
fi

# Create the docker file


if [ -f "./build-assets/$INSTALLER_BIN" ]; then
    docker build --progress plain -t petalinux-build-env .
else
    echo "***** Cannot find $INSTALLER_BIN. Exiting ****"
    exit
fi
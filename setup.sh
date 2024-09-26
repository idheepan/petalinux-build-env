#! /bin/bash
FILE_URL_BASE="https://raw.githubusercontent.com/idheepan/petalinux-build-env/main"
INSTALLER_BIN="petalinux-v2024.1-05202009-installer.run"
if [ ! -f "./$INSTALLER_BIN" ]; then
    read -p "$INSTALLER_BIN was not found. Copy it in the current directory and press enter to continue."
    if [ ! -f "./$INSTALLER_BIN" ]; then
        echo "The file ./$INSTALLER_BIN cannot be found. Exiting."
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

ALIAS_STRING_1="alias build-env='docker build --progress plain -t petalinux-build-env -f container/Dockerfile .'"
ALIAS_STRING_2="alias start-build-env='docker run -v ./build-outputs/projects:/home/petalinux/projects \\
        -v ./build-outputs/cache/sstate-cache:/home/petalinux/cache/sstate-cache \\
        -v ./build-outputs/cache/downloads:/home/petalinux/cache/downloads \\
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
if [ ! -f "Dockerfile" ]; then
    curl -O ${FILE_URL_BASE}/Dockerfile
    curl -O ${FILE_URL_BASE}/.bashrc
    curl -O ${FILE_URL_BASE}/user-account.txt
else
    echo "Using the existing Dockerfile. Not overwriting"
fi

if [ -f "./$INSTALLER_BIN" ]; then
    docker build --progress plain -t petalinux-build-env .
else
    echo "***** Cannot find $INSTALLER_BIN. Exiting ****"
    exit
fi

FILE_PATH=$(pwd)
echo "You can now switch to the build directory and run start-build-env"
echo "=============================="
echo "cd ${FILE_PATH} && start-build-env"
echo "=============================="

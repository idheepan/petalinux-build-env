#! /bin/bash

INSTALLER_BIN="petalinux-v2024.1-05202009-installer.run"
read -p "Copy $INSTALLER_BIN to ./buid-assets. and press enter. " user_input

if [ -f "./build-assets/$INSTALLER_BIN" ]; then
    echo "The file ./build-assets/$INSTALLER_BIN exists."
elif [ -f "./icm3/build-assets/$INSTALLER_BIN" ]; then
    echo "The file ./icm3/build-assets/$INSTALLER_BIN exists."
    cd icm3
else
    echo "$INSTALLER_BIN was not found in ./icm3 or ./build-assets. Cannot continue"
    exit
fi
# Petalinux Build Environment Builder

This repo helps you create a docker container to start building your own custom petalinux builds. 

Windows machine -> ubuntu VM -> petalinux-tools
Windows machine -> ubuntu WSL -> docker container (this-repo) -> petalinux-tools(this-repo)

## Quickstart
Run `curl -s "https://raw.githubusercontent.com/idheepan/petalinux-build-env/main/setup.sh" | bash` from a Ubuntu WSL terminal.

This commands creates a docker container with all the tools necessary to build petalinux images

Navigate to the project directory where you have build-assets and build-outputs directory. Run `start-build-env` command. The projects folder in the container that was just started is mounted to ./build-outputs/projects/

In the container, navigate to ~/projects, and run `petalinux-create project --template zynq --name icm3-petalinux`

## Todo
Handle changes to bashrc and cleanup. Handle multiple petalinux build environments.
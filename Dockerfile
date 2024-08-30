FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ARG PTLNX_INSTALLER=petalinux-v2024.1-05202009-installer.run

# Environment
# Disable user interaction with debian commands.
# see man 7 debconf (may need the debconf-doc pacakge)
ENV DEBIAN_FRONTEND=noninteractive

# Configure dash to bash
# https://superuser.com/questions/715722/how-to-do-dpkg-reconfigure-dash-as-bash-automatically
RUN echo "dash dash/sh boolean false" | debconf-set-selections
RUN dpkg-reconfigure dash

# → Install packages for petalinux
RUN apt-get update -y
RUN apt-get install -y \
    tzdata \
    language-pack-en \
    iproute2 \
    gawk \
    gcc \
    net-tools\
    libncurses5-dev \
    openssl\
    xterm\
    autoconf \
    libtool\
    texinfo\
    zlib1g\
    zlib1g-dev\
    gcc-multilib\
    build-essential\
    automake \
    screen\
    g++\
    xz-utils\
    gcc-11\
    patch\
    python3-jinja2\
    diffutils\
    debianutils\
    iputils-ping\
    python3\
    cpio\
    gnupg \
    less \
    rsync \
    bc \
    lsb-release \
    libtinfo5 \
    dnsutils \
    sudo 

RUN dpkg-reconfigure tzdata

# Create petalinux user and directory
COPY ./user-account.txt .

RUN mkdir -p /opt/petalinux
RUN useradd -s /bin/bash -g users  -m petalinux
RUN usermod -aG sudo petalinux
RUN chpasswd < user-account.txt
RUN rm user-account.txt
RUN chown petalinux:users /opt/petalinux
RUN chmod 755 /opt/petalinux

# Go to petalinux home directory
USER petalinux
WORKDIR /home/petalinux
COPY --chown=petalinux:users ./.bashrc .

# Copy required files
COPY --chown=petalinux:users ./build-assets/$PTLNX_INSTALLER .
RUN chmod +x ./$PTLNX_INSTALLER

# Patch and run installer
RUN ./$PTLNX_INSTALLER -y --platform "arm aarch64" -d /opt/petalinux
RUN rm $PTLNX_INSTALLER

# Containerfile
FROM debian:trixie-slim

# add non-free to source
RUN printf "deb http://deb.debian.org/debian/ trixie main contrib non-free\n" >> /etc/apt/sources.list
RUN dpkg --add-architecture i386 && apt-get update

# install steam
RUN apt-get install -y steam-installer
RUN apt-get install -y mesa-vulkan-drivers libglx-mesa0:i386 mesa-vulkan-drivers:i386 libgl1-mesa-dri:i386

# install misc
RUN apt-get install -y sudo dbus-x11 xvfb procps locales-all pciutils ca-certificates

# create user
RUN useradd -m steam && \
    passwd -d steam && \
    echo "steam ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# set env
ENV PATH="${PATH}:/usr/games:/usr/local/games" \
    DISPLAY=":0"

# fake zenity (otherwise would cause problem in headless)
RUN rm -rf /usr/bin/zenity && \
    printf '%s\n' \
      '#!/bin/sh' \
      'exit 0' \
    > /usr/bin/zenity && \
    chmod 755 /usr/bin/zenity

# update steam
USER steam
WORKDIR /home/steam
RUN STEAM_RUNTIME_LOGGER=0 /usr/games/steam || true

# clean
USER root
RUN apt-get clean && \
    rm -rf /var/cache/apt /var/lib/apt/lists/ /tmp/* /var/tmp/* /var/log/*

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

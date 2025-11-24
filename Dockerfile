# ---------- 1) builder ----------
FROM registry.fedoraproject.org/fedora-minimal:43 AS builder

RUN dnf -y update && \
    dnf -y install \
        shadow-utils sudo util-linux util-linux-script xz \
        xorg-x11-server-Xvfb dbus-x11 && \
    dnf clean all && rm -rf /var/cache/dnf

RUN dnf -y install \
      https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
      https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm && \
    dnf -y install steam && \
    dnf clean all && rm -rf /var/cache/dnf

RUN useradd -m steam && \
    passwd -d steam && \
    echo "steam ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

USER steam
WORKDIR /home/steam

RUN script -q -c "steam -shutdown" /dev/null || true

USER root
RUN mkdir -p /runtime && \
    cp -a /usr /runtime/usr && \
    cp -a /etc /runtime/etc && \
    cp -a /lib /runtime/lib && \
    cp -a /lib64 /runtime/lib64 && \
    cp -a /home /runtime/home && \
    mkdir -p /runtime/tmp/.X11-unix && \
    chmod 1777 /runtime/tmp/.X11-unix

# ---------- 2) runtime ----------
FROM registry.fedoraproject.org/fedora-minimal:43 AS runtime

RUN useradd -m steam

COPY --from=builder /runtime/ /

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh \
    && rm -rf /var/cache/dnf /usr/share/doc /usr/share/man /usr/share/locale

USER steam
WORKDIR /home/steam

ENV DISPLAY=:0

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

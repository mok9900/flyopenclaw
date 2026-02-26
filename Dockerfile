FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive \
    TZ=UTC \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    DISPLAY=:1 \
    OPENCLAW_PORT=18789 \
    OPENCLAW_HOME=/data/.openclaw \
    VNC_PORT=8443

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    wget \
    gnupg \
    git \
    supervisor \
    dbus-x11 \
    xdg-utils \
    xterm \
    xfce4 \
    xfce4-terminal \
    thunar \
    fonts-noto-color-emoji \
    locales \
    && locale-gen en_US.UTF-8 \
    && rm -rf /var/lib/apt/lists/*

# Node.js 22 for OpenClaw
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get update \
    && apt-get install -y --no-install-recommends nodejs \
    && npm install -g pnpm openclaw@latest \
    && rm -rf /var/lib/apt/lists/*

# Google Chrome
RUN wget -q -O /tmp/google-chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
    && apt-get update \
    && apt-get install -y /tmp/google-chrome.deb \
    && rm /tmp/google-chrome.deb \
    && rm -rf /var/lib/apt/lists/*

# KasmVNC (Ubuntu 24.04 compatible package)
RUN wget -q -O /tmp/kasmvncserver.deb https://github.com/kasmtech/KasmVNC/releases/download/v1.3.3/kasmvncserver_jammy_1.3.3_amd64.deb \
    && apt-get update \
    && apt-get install -y /tmp/kasmvncserver.deb \
    && rm /tmp/kasmvncserver.deb \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -m -s /bin/bash kasm \
    && mkdir -p /data/openclaw /var/log/supervisor \
    && chown -R kasm:kasm /data /home/kasm

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY scripts/start-kasmvnc.sh /usr/local/bin/start-kasmvnc.sh
COPY scripts/start-openclaw.sh /usr/local/bin/start-openclaw.sh

RUN chmod +x /usr/local/bin/start-kasmvnc.sh /usr/local/bin/start-openclaw.sh

EXPOSE 8443 18789
VOLUME ["/data"]

CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

#!/usr/bin/env bash
set -euo pipefail

export USER=kasm
export HOME=/home/kasm
export DISPLAY=:1

mkdir -p "$HOME/.vnc" /data/openclaw
chown -R kasm:kasm "$HOME/.vnc" /data/openclaw

VNC_PASSWORD="${VNC_PASSWORD:-17891789}"
su - kasm -c "printf '%s\n' '${VNC_PASSWORD}' | kasmvncpasswd -w -u kasm stdin"

# Clean stale locks from previous boot
rm -f /tmp/.X1-lock /tmp/.X11-unix/X1

exec su - kasm -c "vncserver :1 -select-de xfce -geometry 1920x1080 -depth 24 -websocketPort ${VNC_PORT:-8443} -interface 0.0.0.0 -SecurityTypes VNC"

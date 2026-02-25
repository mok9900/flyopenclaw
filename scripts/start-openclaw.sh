#!/usr/bin/env bash
set -euo pipefail

export USER=kasm
export HOME=/home/kasm

mkdir -p /data/openclaw
chown -R kasm:kasm /data/openclaw
cd /data/openclaw

if [ ! -f /data/openclaw/.initialized ]; then
  touch /data/openclaw/.initialized
fi

exec su - kasm -c "openclaw gateway --port ${OPENCLAW_PORT:-18789} --verbose"

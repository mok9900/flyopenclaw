#!/usr/bin/env bash
set -euo pipefail

export USER=kasm
export HOME=/home/kasm
export OPENCLAW_HOME="${OPENCLAW_HOME:-/data/.openclaw}"

mkdir -p /data/openclaw "$OPENCLAW_HOME"
chown -R kasm:kasm /data/openclaw "$OPENCLAW_HOME"
cd /data/openclaw

if [ ! -f /data/openclaw/.initialized ]; then
  touch /data/openclaw/.initialized
fi

# Ensure persistent OpenClaw config exists on Fly volume and passes gateway guardrail.
if [ ! -f "$OPENCLAW_HOME/openclaw.json" ]; then
  cat > "$OPENCLAW_HOME/openclaw.json" <<'JSON'
{
  "gateway": {
    "mode": "local"
  }
}
JSON
  chown kasm:kasm "$OPENCLAW_HOME/openclaw.json"
fi

# Merge/repair gateway.mode=local even if config already exists.
node -e '
const fs = require("fs");
const p = process.argv[1];
let cfg = {};
try { cfg = JSON.parse(fs.readFileSync(p, "utf8")); } catch (_) { cfg = {}; }
if (!cfg.gateway || typeof cfg.gateway !== "object") cfg.gateway = {};
if (cfg.gateway.mode !== "local") cfg.gateway.mode = "local";
fs.writeFileSync(p, JSON.stringify(cfg, null, 2) + "\n");
' "$OPENCLAW_HOME/openclaw.json"
chown kasm:kasm "$OPENCLAW_HOME/openclaw.json"

OPENCLAW_EXTRA_FLAGS=""
if [ "${OPENCLAW_ALLOW_UNCONFIGURED:-0}" = "1" ]; then
  OPENCLAW_EXTRA_FLAGS="--allow-unconfigured"
fi

exec su - kasm -c "OPENCLAW_HOME='$OPENCLAW_HOME' openclaw gateway --port ${OPENCLAW_PORT:-18789} --verbose ${OPENCLAW_EXTRA_FLAGS}"
